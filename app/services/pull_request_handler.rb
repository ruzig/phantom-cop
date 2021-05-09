# frozen_string_literal: true

class PullRequestHandler
  attr_reader :payload, :action, :pull_request

  def initialize(payload:, action:)
    @payload = payload
    @action = action
    @pull_request = payload['pull_request']
  end

  def call
    return unless %w[opened edited reopened].include?(action)

    if repository.sentry_project_id
      CopCheckJob
        .perform_later(repository.github_account.id,
                       repository.github_id,
                       pull_request['number'])
      return
    end

    if action == 'opened'
      GithubSentryLinkJob
        .perform_later(repository.github_account.id,
                       repository.github_id,
                       pull_request['number'])
    end
  end

  private

  def repository
    repo = pull_request['head']['repo'] || payload['repository']
    account = GithubAccount.find_by(github_id: repo['owner']['id'])
    return unless account

    @repository ||= Repository
                    .create_with(repo.slice(:node_id, :name,
                                            :full_name, :private))
                    .find_or_create_by(github_account: account,
                                       github_id: repo[:id])
  end
end
