# frozen_string_literal: true

module Sentry
  class FetchProjectEventsJob < ApplicationJob
    def perform(sentry_project_id)
      service = SentryEventsFetcher.new(sentry_project_id)
      service.call
    end
  end
end
