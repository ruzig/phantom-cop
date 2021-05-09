class CreateSentryProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :sentry_projects do |t|
      t.string :project_id
      t.string :project_slug
      t.uuid :installation_id
      t.index :installation_id

      t.timestamps
    end
  end
end
