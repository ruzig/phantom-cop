# frozen_string_literal: true

module Sentry
  class EstablishmentJob < ApplicationJob
    def perform(params)
      service = SentryEstablishment.new(params)
      service.call
    end
  end
end
