class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns, id: :uuid do |t|
      # Foreign keys (relationships)
      t.references :creator, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :category, null: false, foreign_key: true, type: :uuid
      
      # Campaign details
      t.string :title
      t.integer :goal_amount, null: false
      t.integer :current_amount, default: 0, null: false
      t.date :end_date, null: false
      t.date :start_date, null: false
      t.string :status, null: false, default: "active"

      # Tracking
      t.integer :view_count, default: 0, null: false

      t.timestamps
    end

    # Indexes for performance
    add_index :campaigns, :status
    add_index :campaigns, :created_at
    add_index :campaigns, :current_amount
    add_index :campaigns, [:creator_id, :status]
  end
end
