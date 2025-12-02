class CreateContributions < ActiveRecord::Migration[8.1]
  def change
    create_table :contributions, id: :uuid do |t|
      t.references :campaign, null: false, foreign_key: true, type: :uuid
      t.references :contributor, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.integer :amount
      t.string :status, null: false, default: "pending"
      t.string :payment_reference
      t.datetime :contributed_at, null: false

      t.timestamps
    end

    # Indexes
    add_index :contributions, :status
    add_index :contributions, :payment_reference, unique: true
    add_index :contributions, :contributed_at
    add_index :contributions, [:campaign_id, :status]
  end
end
