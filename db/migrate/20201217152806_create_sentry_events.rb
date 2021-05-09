class CreateSentryEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :sentry_events do |t|
      t.string :event_id
      t.uuid :installation_id
      t.string :project_id
      t.text :filename
      t.integer :line_number
      t.integer :column_number
      t.index :installation_id
      t.index :project_id

      t.timestamps
    end
  end
end
