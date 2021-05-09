# frozen_string_literal: true

class PullRequestCommentHandler
  CREATE_ACTION = 'created'

  def initialize(payload:, action:)
    @payload = payload
    @action = action
  end

  def call
    find_or_create_repository
    return unless sentry_github_installation?

    PullRequestCommentHandlerJob.perform_now(
      installation_id, repository_id, comment, comment_id, pull_request_id
    )
  end

  private

  attr_reader :payload, :action

  def sentry_github_installation?
    action == CREATE_ACTION && comment.start_with?(GithubBotCommands::SET_SENTRY_COMMAND)
  end

  def installation_id
    @installation_id ||= payload.dig(:installation, :id)
  end

  def comment
    @comment ||= payload.dig(:comment, :body)
  end

  def comment_id
    @comment_id ||= payload.dig(:comment, :id)
  end

  def repository_id
    @repository_id ||= payload.dig(:repository, :id)
  end

  def pull_request_id
    @pull_request_id ||= payload.dig(:issue, :number) || payload.dig(:pull_request, :number)
  end

  def find_or_create_repository
    repository_payload = payload[:repository]
    Repository.find_or_create_by!(
      name: repository_payload[:name],
      full_name: repository_payload[:full_name],
      github_id: repository_payload[:id],
      github_account: github_account
    )
  end

  def github_account
    @github_account ||= GithubAccount.find_by(installation_id: installation_id)
  end
end
