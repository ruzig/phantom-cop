class AddTokenExpiredAtToSentryInstallations < ActiveRecord::Migration[6.0]
  def change
    add_column :sentry_installations, :token_expired_at, :datetime
  end
end
