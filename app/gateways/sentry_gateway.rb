# frozen_string_literal: true

class SentryGateway < ApplicationGateway
  HOST = 'https://sentry.io'
  LIMITED_REQUEST_TIMES = 10
  DELAY_TIME = 1

  def initialize(installation_id)
    @installation_id = installation_id
    @requested_times = 0
  end

  def fetch_refesh_token(code)
    payload = { grant_type: 'authorization_code', code: code }
    authorizations_request payload
  end

  def retrive_refresh_token(refresh_token)
    payload = { grant_type: 'refresh_token', refresh_token: refresh_token }
    authorizations_request payload
  end

  def fetch_projects(token, organization_slug)
    url = "api/0/organizations/#{organization_slug}/projects/"
    result = fetch_with_token(url, token)
    result.body
  end

  def fetch_project_events(token, organization_slug, project_slug)
    url = "api/0/projects/#{organization_slug}/#{project_slug}/events/"
    params = { full: true }
    fetch_with_token(url, token, params)
  end

  def fetch_issue_events(token, issue_id)
    url = "api/0/issues/#{issue_id}/events/"
    params = { full: true }
    result = fetch_with_token(url, token, params)
    result.body
  end

  def fetch_event_details(token, organization_slug:, project_slug:, event_id:)
    url = "api/0/projects/#{organization_slug}/#{project_slug}/events/#{event_id}/"
    result = fetch_with_token(url, token)
    result.body
  end

  def fetch_project_issues(token, organization_slug, project_slug, params = {})
    url = "api/0/projects/#{organization_slug}/#{project_slug}/issues/"
    fetch_with_token(url, token, params)
  end

  private

  attr_reader :installation_id, :requested_times

  def fetch_with_token(url, token, params = {})
    delay_request if requested_times > LIMITED_REQUEST_TIMES
    @requested_times += 1
    response = http_client.get(url + "?#{params.to_param}") do |request|
      request.headers['Authorization'] = "Bearer #{token}"
    end

    response.status == TOO_MANY_REQUESTS_CODE &&
      raise(TooManyRequestsError, "Too many request, URL: #{url}")

    response
  rescue TooManyRequestsError => e
    Rails.logger.warning("SentryGateway: #{e.inspect}")
    delay_request
    retry
  end

  def delay_request
    sleep DELAY_TIME
    @requested_times = 0
  end

  def authorizations_request(payload)
    payload = payload.merge(
      client_id: Rails.application.credentials.sentry[:client_id],
      client_secret: Rails.application.credentials.sentry[:client_secret]
    )
    url = "api/0/sentry-app-installations/#{installation_id}/authorizations/"
    result = http_client.post(url, payload.to_json)
    result.body
  end

  def http_client
    Faraday.new HOST do |conn|
      conn.request :json
      conn.response :json
      conn.adapter Faraday.default_adapter
    end
  end
end
