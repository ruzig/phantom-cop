# frozen_string_literal: true

module Hooks
  class SentryController < ApplicationController
    def create
      sentry_params = params.require(:sentry).permit!
      Sentry::EstablishmentJob.perform_later(sentry_params)
    end
  end
end
