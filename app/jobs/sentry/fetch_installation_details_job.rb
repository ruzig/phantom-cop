# frozen_string_literal: true

module Sentry
  class FetchInstallationDetailsJob < ApplicationJob
    def perform(sentry_installation_id)
      sentry_installation = SentryInstallation.find sentry_installation_id

      service = SentryProjectsFetcher.new(sentry_installation.id)
      service.call

      enqueue_event_fetcher_job(sentry_installation)
    end

    private

    def enqueue_event_fetcher_job(sentry_installation)
      sentry_installation.sentry_projects.each do |sentry_project|
        Sentry::FetchProjectEventsJob.perform_later(sentry_project.id)
      end
    end
  end
end
