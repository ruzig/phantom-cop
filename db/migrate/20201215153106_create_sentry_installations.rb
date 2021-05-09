class CreateSentryInstallations < ActiveRecord::Migration[6.0]
  def change
    create_table :sentry_installations do |t|
      t.string :organization_slug
      t.string :refresh_token
      t.uuid :installation_id
      t.json :external_data
      t.string :status
      t.index :installation_id

      t.timestamps
    end
  end
end
