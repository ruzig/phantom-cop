# frozen_string_literal: true

module Github
  class FetchGithubDataJob < ApplicationJob
    queue_as :default

    def perform(account_id)
      account = GithubAccount.find_by(id: account_id)
      unless account
        puts "This account #{account_id} is not existed."
        return
      end

      client = GithubGateway.new.installation_client(account.installation_id)

      RepositoryFetcher.new(client, account).perform
    end
  end
end
