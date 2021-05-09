# frozen_string_literal: true

class PullRequestCop
  def self.call(*args)
    new(*args).call
  end

  def initialize(account_id:, repo_id:, pull_request_number:)
    @account_id = account_id
    @repo_id = repo_id
    @pull_request_number = pull_request_number
  end

  def call
    unless processable?
      puts "Unnable to process github_account #{account_id} and repo_id #{repo_id}"
      return
    end
    comments_payload = parse_comments_payload
    return if comments_payload.blank?

    puts "PullRequestCop: #{comments_payload.as_json}"

    github_client.create_pull_request_review(
      repo_id,
      pull_request_number,
      event: 'COMMENT',
      comments: comments_payload
    )
    github_pull_request.update!(filenames: pull_request_filenames)
  end

  private

  attr_reader :account_id, :repo_id, :pull_request_number

  def processable?
    github_account.present? && repository.present?
  end

  def github_pull_request
    @github_pull_request ||= GithubPullRequest.find_or_create_by(
      pull_request_number: pull_request_number,
      reponsitory_github_id: repo_id
    )
  end

  def github_account
    @github_account ||= GithubAccount.find_by(id: account_id)
  end

  def repository
    @repository ||= Repository.find_by(github_id: repo_id)
  end

  def github_client
    @github_client ||= GithubGateway.new.installation_client(
      github_account.installation_id
    )
  end

  def pull_request_files
    @pull_request_files ||= github_client.pull_request_files(repo_id, pull_request_number)
  end

  def pull_request_filenames
    pull_request_files.map { |file| file['filename'] }.uniq
  end

  def parse_comments_payload
    pull_request_files.map do |file|
      filename = file['filename']
      errors_count = SentryEvent.where('filename iLIKE ?', "%#{filename}%")
                                .where(project_id: repository.sentry_project_id)
                                .pluck(:events_counter).map(&:to_i).sum
      next if errors_count.zero? || github_pull_request.filenames.include?(filename)

      body = "**#{ActionController::Base.helpers.pluralize(errors_count, 'sentry event')}** happen in this file"
      { path: filename, position: 1, body: body }
    end.compact
  end
end
