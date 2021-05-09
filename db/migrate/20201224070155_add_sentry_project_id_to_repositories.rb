class AddSentryProjectIdToRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :sentry_project_id, :string
  end
end
