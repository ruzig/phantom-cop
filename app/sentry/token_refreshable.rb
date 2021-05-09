# frozen_string_literal: true

module TokenRefreshable
  private

  def refresh_token
    return unless token_refreshable?

    result = gateway.retrive_refresh_token(sentry_installation.refresh_token)
    update_sentry_installation!(result)
  end

  def update_sentry_installation!(result)
    sentry_installation.refresh_token = result['refreshToken']
    sentry_installation.token = result['token']
    sentry_installation.token_expired_at = result['expiresAt']
    sentry_installation.external_data = result
    sentry_installation.save!
  end

  def token_refreshable?
    sentry_installation.token.blank? ||
      sentry_installation.token_expired_at.blank? ||
      sentry_installation.token_expired_at <= Time.current + 15.minutes
  end

  def token
    sentry_installation.token
  end
end
