class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      t.string  :username
      t.string  :city
      t.text    :bio
      t.string  :avatar_url
      t.datetime :email_verified_at
      t.datetime :phone_verified_at
      t.datetime :deleted_at
    end

    add_index :users, :username, unique: true, where: "username IS NOT NULL"
    add_index :users, :deleted_at
  end
end
