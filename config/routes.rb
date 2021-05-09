# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :hooks do
    resources :sentry, only: :create
    post '/github/event_handler', to: 'github#event_handler'
    post '/github/bill_handler', to: 'github#marketplace'
  end

  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # Protect against timing attacks:
      # - See https://codahale.com/a-lesson-in-timing-attacks/
      # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
      encrypted_inputed_username = ::Digest::SHA256.hexdigest(username)
      encrypted_system_username = ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq[:username])
      encrypted_inputed_password = ::Digest::SHA256.hexdigest(password)
      encrypted_system_password = ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq[:password])
      ActiveSupport::SecurityUtils.secure_compare(encrypted_inputed_username, encrypted_system_username) &
        ActiveSupport::SecurityUtils.secure_compare(encrypted_inputed_password, encrypted_system_password)
    end
  end

  mount Sidekiq::Web => '/sidekiq'
end
