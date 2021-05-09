# frozen_string_literal: true

class SentryProjectsFetcher
  include TokenRefreshable

  def initialize(sentry_installation_id)
    @sentry_installation_id = sentry_installation_id
  end

  def call
    refresh_token
    response = gateway.fetch_projects(token, sentry_installation.organization_slug)
    response.each do |data|
      SentryProject.find_or_create_by!(
        project_id: data['id'],
        project_slug: data['slug'],
        installation_id: sentry_installation.installation_id
      )
    end
  end

  private

  attr_reader :sentry_installation_id

  def sentry_installation
    @sentry_installation ||= SentryInstallation.find(sentry_installation_id)
  end

  def gateway
    @gateway ||= SentryGateway.new(sentry_installation.installation_id)
  end
end
