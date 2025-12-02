class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.references :campaign, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.datetime :subscribed_at, null: false

      t.timestamps
    end

    # Ensure a user can only subscribe once to a campaign
    add_index :subscriptions, [:campaign_id, :user_id], unique: true
  end
end
