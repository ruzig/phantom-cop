class CreateGithubAccount < ActiveRecord::Migration[6.0]
  def change
    create_table :github_accounts do |t|
      t.string :login
      t.integer :github_id
      t.string :node_id
      t.string :avatar_url
      t.string :html_url
      t.string :account_type
      t.integer :installation_id

      t.timestamps
    end

    add_index :github_accounts, :github_id
  end
end
