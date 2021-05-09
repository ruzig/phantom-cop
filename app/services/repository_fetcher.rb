# frozen_string_literal: true

class RepositoryFetcher
  attr_reader :client, :account

  def initialize(client, account)
    @client = client
    @account = account
  end

  def perform
    puts "Fetching repositories from #{account.login}"

    first_batch_prs = if account.account_type == 'User'
                        client.repositories(account.login, per_page: 100)
                      else
                        client.org_repos(account.login, per_page: 100)
                      end
    last_response = client.last_response

    result = first_batch_prs.map { |repo| insert_repo(repo) }

    while last_response.rels[:next]
      if client.rate_limit.remaining < 50
        puts "Sleep in fetching repository #{client.rate_limit.inspect}"
        sleep((client.rate_limit.resets_in + 5).seconds)
      end
      last_response = last_response.rels[:next].get
      result.concat(last_response.data.map { |repo| insert_repo(repo) })
    end

    puts "Inserted #{result.count} repositories: #{result.map(&:id).inspect}"

    result
  end

  def insert_repo(repo)
    Repository
      .create_with(repo.to_h.slice(:node_id, :name,
                                   :full_name, :private))
      .find_or_create_by(github_account: account,
                         github_id: repo[:id])
  end
end
