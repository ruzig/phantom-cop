# frozen_string_literal: true

class GithubBotCommands
  BOT_COMMANDS = [
    SET_SENTRY_COMMAND = 'set_sentry'
  ].freeze

  class UnsupportedAction < StandardError; end
  def initialize(github_installation_id:, github_repository_id:, command:, comment_id:, pull_request_id:)
    @github_installation_id = github_installation_id
    @command = command
    @github_repository_id = github_repository_id
    @comment_id = comment_id
    @pull_request_id = pull_request_id
  end

  def execute
    return unless valid_actions?

    case action
    when SET_SENTRY_COMMAND
      return submit_not_found_comment if sentry_project.blank?

      repository.update!(sentry_project_id: sentry_project.project_id)
      submit_found_comment
    else
      raise UnsupportedAction, "#{action} is unsuported"
    end
  end

  private

  attr_reader :github_installation_id, :github_repository_id, :command, :comment_id, :pull_request_id

  def valid_actions?
    BOT_COMMANDS.include?(action)
  end

  def parsed_command
    @parsed_command ||= command.split
  end

  def action
    @action ||= parsed_command.first
  end

  def repository
    @repository ||= Repository.find_by(
      github_account_id: github_account.id,
      github_id: github_repository_id
    )
  end

  def github_account
    @github_account ||= GithubAccount.find_by(installation_id: github_installation_id)
  end

  def submit_not_found_comment
    create_pull_request_comment_reply('Can not map information please try again')
  end

  def submit_found_comment
    create_pull_request_comment_reply('done!')
  end

  def create_pull_request_comment_reply(body)
    github_client.create_pull_request_comment_reply(
      repository.full_name,
      pull_request_id,
      body,
      comment_id
    )
  end

  def github_client
    @github_client ||= GithubGateway.new.installation_client(github_installation_id)
  end

  def sentry_project
    @sentry_project ||=
      begin
        sentry_projects = SentryProject.where(project_id: parsed_command.third, project_slug: parsed_command.second)
        SentryProject.where(project_id: parsed_command.second, project_slug: parsed_command.third)
                     .or(sentry_projects).first
      end
  end
end
