class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :label,          null: false, default: "Home"
      t.string  :recipient_name, null: false
      t.string  :line1,          null: false
      t.string  :line2
      t.string  :city
      t.string  :state
      t.string  :postal_code
      t.string  :country,        null: false, default: "IN"
      t.string  :phone,          null: false
      t.boolean :is_default,     null: false, default: false
      t.timestamps
    end

    add_index :addresses, %i[user_id is_default]
  end
end
