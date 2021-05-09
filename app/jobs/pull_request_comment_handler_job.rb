class PullRequestCommentHandlerJob < ApplicationJob
  queue_as :default

  def perform(github_installation_id, github_repository_id, command, comment_id, pull_request_id)
    commander = GithubBotCommands.new(
      github_installation_id: github_installation_id,
      github_repository_id: github_repository_id,
      command: command,
      comment_id: comment_id,
      pull_request_id: pull_request_id
    )
    commander.execute
  end
end
