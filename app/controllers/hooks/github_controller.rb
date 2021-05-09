# frozen_string_literal: true

module Hooks
  class GithubController < ApplicationController
    before_action :verify_webhook_signature

    def marketplace
      payload = params.require(:github).permit!
      event_action = payload['action']
      MarketplaceHandler.new(payload: payload, action: event_action).call

      render status: 200
    end

    def event_handler
      payload = params.require(:github).permit!
      event_action = payload['action']
      klass = mapping.dig(request.headers['X-GitHub-Event'].to_sym)
      klass&.new(payload: payload, action: event_action)&.call

      render status: 200
    end

    def auth_handler
      render status: 200
    end

    private

    def mapping
      {
        installation: InstallationHandler,
        integration_installation: InstallationHandler,
        marketplace_purchase: MarketplaceHandler,
        pull_request: PullRequestHandler,
        issue_comment: PullRequestCommentHandler,
        pull_request_review_comment: PullRequestCommentHandler
      }
    end

    def verify_webhook_signature
      head(401) unless GithubGateway.new.verify_webhook_signature(request)
    end
  end
end
