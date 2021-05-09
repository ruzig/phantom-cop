# frozen_string_literal: true

class GithubGateway < ApplicationGateway
  def verify_webhook_signature(request)
    webhook_secret = Rails.application.credentials.github[:webhook_secret]

    request.body.rewind
    payload_body = request.body.read

    our_digest = 'sha256=' + OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      webhook_secret,
      payload_body
    )

    Rack::Utils
      .secure_compare(our_digest,
                      request.env['HTTP_X_HUB_SIGNATURE_256'])
  end

  def installation_client(installation_id, logger = Rails.logger)
    installation_token = app_client
                         .create_app_installation_access_token(
                           installation_id,
                           accept: 'application/vnd.github.machine-man-preview+json'
                         )[:token]
    Octokit::Client.new(bearer_token: installation_token)
  rescue Octokit::NotFound => e
    logger.error("Github: Can not authorize installation: #{e.inspect}")
    nil
  end

  def app_client
    payload = {
      # The time that this JWT was issued, _i.e._ now.
      iat: Time.now.to_i,

      # JWT expiration time (10 minute maximum)
      exp: Time.now.to_i + (10 * 60),

      # Your GitHub App's identifier number
      iss: Rails.application.credentials.github[:app_identifier]
    }

    # Cryptographically sign the JWT.
    github_private_key = Rails.application
                              .credentials
                              .github[:private_key]
                              .gsub('$ ', "\n")
    private_key = OpenSSL::PKey::RSA.new(github_private_key)
    jwt = JWT.encode(payload, private_key, 'RS256')

    @app_client ||= Octokit::Client.new(bearer_token: jwt)
  end
end
