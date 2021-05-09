# frozen_string_literal: true

class InstallationHandler
  attr_reader :payload, :action, :installation, :repositories

  def initialize(payload:, action:)
    @payload = payload
    @action = action
    @installation = payload['installation']
    @repositories = payload['repositories'] || []
  end

  def call
    if action == 'deleted'
      delete_account
    else
      account = create_account
      Github::FetchGithubDataJob.perform_later(account.id)
    end
  end

  private

  def delete_account
    Account.find_by(github_id: installation.dig(:account, :id)).destroy
  end

  def create_account
    data = acc_params.slice(:login, :node_id, :avatar_url, :html_url, :account_type, :installation_id)
    acc = GithubAccount
          .create_with(data)
          .find_or_create_by(github_id: acc_params[:id])
    acc.update(data)
    acc
  end

  def acc_params
    acc = installation[:account]
    acc[:account_type] = acc.delete(:type)
    acc[:installation_id] = installation[:id]
    acc
  end
end
