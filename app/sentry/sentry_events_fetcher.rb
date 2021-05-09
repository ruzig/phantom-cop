# frozen_string_literal: true

class SentryEventsFetcher
  include TokenRefreshable

  def initialize(sentry_project_id)
    @sentry_project_id = sentry_project_id
  end

  def call
    refresh_token

    response = fetch_project_issues
    response_body = response.body
    sentry_project.sentry_events.delete_all if response_body.first['id'].present?
    response_body.each { |issue| find_or_create_events!(issue) }
    paginating_response = parse_paginating_params response
    while paginating_response
      response = fetch_project_issues(cursor: paginating_response['cursor'])
      paginating_response = parse_paginating_params response
      response.body.each { |issue| find_or_create_events!(issue) }
    end
  end

  private

  attr_reader :sentry_project_id

  def production_environment?(issue)
    response = fetch_issue_events(issue['id'])
    result = response.first
    tags = result['tags']
    return if tags.blank?

    tags.any? do |tag|
      tag['key'] == 'environment' && tag['value'] == 'production'
    end
  end

  def parse_paginating_params(response)
    link = response.headers['link']
    cursor_params = link.split(',')
    next_params = cursor_params.find do |param|
      param.include?('rel="next"') && param.include?('results="true"')
    end

    return if next_params.blank?

    paginating_response = next_params.split(';')
    paginating_response.shift

    paginating_response.map { |l| l.strip.split('=') }.to_h
  end

  def issue_filename(issue)
    filename = issue.dig('metadata', 'filename')
    return filename if filename.present?

    response = fetch_issue_events(issue['id'])
    entries = response.first['entries']
    return if entries.blank?

    first_entries = entries.first

    values = first_entries.dig('data', 'values')
    return if values.blank?

    value = values.first
    frames = value.dig('stacktrace', 'frames')

    return if frames.blank?

    frames.last.dig('filename')
  end

  def find_or_create_events!(issue)
    return unless production_environment?(issue)

    filename = issue_filename(issue)
    return if filename.blank?

    event = SentryEvent.find_or_initialize_by(
      project_id: sentry_project.project_id,
      installation_id: sentry_installation.installation_id,
      event_id: issue['id'],
      filename: filename
    )
    events_counter = event.events_counter.to_i
    event.events_counter = events_counter + issue['count'].to_i
    event.save!
  end

  def sentry_project
    @sentry_project ||= SentryProject.find(sentry_project_id)
  end

  def sentry_installation
    @sentry_installation ||= sentry_project.sentry_installation
  end

  def fetch_issue_events(issue_id)
    gateway.fetch_issue_events(token, issue_id)
  end

  def fetch_project_issues(params = {})
    gateway.fetch_project_issues(
      token,
      sentry_installation.organization_slug,
      sentry_project.project_slug,
      params
    )
  end

  def gateway
    @gateway ||= SentryGateway.new(sentry_installation.installation_id)
  end
end
