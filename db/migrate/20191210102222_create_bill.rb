class CreateBill < ActiveRecord::Migration[6.0]
  def change
    create_table :bills do |t|
      t.string :billing_cycle
      t.boolean :on_free_trial
      t.boolean :active, default: true
      t.datetime :free_trial_ends_on
      t.datetime :next_billing_date
      t.string :organization_billing_email
      t.references :github_account

      t.timestamps
    end
  end
end
