class CreateCampaignComments < ActiveRecord::Migration[8.1]
  def change
    create_table :campaign_comments, id: :uuid do |t|
      t.references :campaign, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.text :content, null: false
      t.string :comment_type, null: false, default: "comment"

      t.timestamps
    end

    add_index :campaign_comments, :comment_type
    add_index :campaign_comments, [:campaign_id, :created_at]
  end
end
