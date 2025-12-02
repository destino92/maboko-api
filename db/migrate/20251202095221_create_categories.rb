class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    # Index for fast lookups
    add_index :categories, :slug, unique: true
    add_index :categories, :name, unique: true
  end
end
