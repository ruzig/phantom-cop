# frozen_string_literal: true

class ApplicationGateway
  TOO_MANY_REQUESTS_CODE = 429
  class TooManyRequestsError < StandardError; end
end
