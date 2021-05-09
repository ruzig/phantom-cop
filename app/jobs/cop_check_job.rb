# frozen_string_literal: true

class CopCheckJob < ApplicationJob
  queue_as :default

  def perform(account_id, repo_id, pull_request_number)
    PullRequestCop.call(
      account_id: account_id,
      repo_id: repo_id,
      pull_request_number: pull_request_number
    )
  end
end
