class AddTokenToSentryInstallations < ActiveRecord::Migration[6.0]
  def change
    add_column :sentry_installations, :token, :text
  end
end
