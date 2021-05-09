class CreateGithubPullRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :github_pull_requests do |t|
      t.integer :pull_request_number
      t.integer :reponsitory_github_id
      t.text :filenames, array: true, default: []

      t.timestamps
    end
  end
end
