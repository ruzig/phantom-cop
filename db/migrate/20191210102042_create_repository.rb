class CreateRepository < ActiveRecord::Migration[6.0]
  def change
    create_table :repositories do |t|
      t.integer :github_id
      t.string :node_id
      t.string :name
      t.string :full_name
      t.boolean :private
      t.references :github_account

      t.timestamps
    end

    add_index :repositories, :github_id
  end
end
