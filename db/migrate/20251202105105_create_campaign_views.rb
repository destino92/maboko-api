class CreateCampaignViews < ActiveRecord::Migration[8.1]
  def change
    create_table :campaign_views, id: :uuid do |t|
      t.references :campaign, null: false, foreign_key: true, type: :uuid
      t.datetime :viewed_at, null: false

      t.timestamps
    end

    add_index :campaign_views, :viewed_at
    add_index :campaign_views, [:campaign_id, :viewed_at]
  end
end
