# frozen_string_literal: true

class SentryEstablishment
  CREATED_ACTION = 'created'
  DELETED_ACTION = 'deleted'

  def initialize(params)
    @installation_params = params.dig(:data, :installation)
    @action = params[:action]
    @installation_id = installation_params[:uuid]
    @organization_slug = installation_params.dig(:organization, :slug)
  end

  def call
    created? ? handle_creating_installation! : handle_updating_installation!
  end

  private

  attr_reader :installation_params, :action, :installation_id, :organization_slug

  def gateway
    @gateway ||= SentryGateway.new(installation_id)
  end

  def created?
    action == CREATED_ACTION
  end

  def handle_updating_installation!
    installation = SentryInstallation.find_by(
      installation_id: installation_id,
      organization_slug: organization_slug
    )
    installation.update!(status: DELETED_ACTION)
  end

  def handle_creating_installation!
    code = installation_params[:code]
    response = gateway.fetch_refesh_token(code)
    installation = SentryInstallation.new(
      installation_id: installation_id,
      organization_slug: organization_slug,
      refresh_token: response['refreshToken'],
      token: response['token'],
      token_expired_at: response['expiresAt'],
      status: CREATED_ACTION,
      external_data: installation_params.merge(response)
    )
    installation.save!

    Sentry::FetchInstallationDetailsJob.perform_later(installation.id)
  end
end
