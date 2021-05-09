# frozen_string_literal: true

namespace :sentry do
  desc 'fetch installation detail'
  task fetch_installation_details: :environment do
    SentryInstallation.find_each do |sentry_installation|
      Sentry::FetchInstallationDetailsJob.perform_later(sentry_installation.id)
    end
  end
end
