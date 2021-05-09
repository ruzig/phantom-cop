# frozen_string_literal: true

class GithubSentryLinkJob < ApplicationJob
  queue_as :default

  def perform(account_id, repo_id, pull_request_number)
    account = GithubAccount.find_by(id: account_id)
    unless account
      puts "This account #{account_id} is not existed."
      return
    end

    client = GithubGateway.new.installation_client(account.installation_id)
    first_file = client.pull_request_files(repo_id, pull_request_number).first

    body = 'To show sentry bugs in this repository. Reply `set-sentry project-id project-name`. '

    result = first_file['patch'].scan /\+(\d{0,})\,\d{0,} \@/
    position = result.flatten.last.to_i - 1

    comments = [{ path: first_file['filename'], position: position, body: body }]
    options = { event: 'COMMENT', comments: comments }
    client.create_pull_request_review(repo_id, pull_request_number, options)
  end
end
