class AddFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :sex, :string

    # Add index for fast lookups
    add_index :users, :phone_number, unique: true
  end
end
