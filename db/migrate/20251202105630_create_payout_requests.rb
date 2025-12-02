class CreatePayoutRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :payout_requests, id: :uuid do |t|
      t.references :campaign, null: false, foreign_key: true, type: :uuid
      t.references :requestor, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.integer :amount, null: false
      t.string :status, null: false, default: "requested"
      t.string :disbursement_reference # Transaction ID from payout provider
      t.datetime :requested_at, null: false
      t.datetime :processed_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :payout_requests, :status
    add_index :payout_requests, [:campaign_id, :status]
  end
end
