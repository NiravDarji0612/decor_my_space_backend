class CreateAddOns < ActiveRecord::Migration[8.0]
  def change
    create_table :add_ons do |t|
      t.string  :key,         null: false
      t.string  :label,       null: false
      t.text    :description
      t.integer :price_cents, null: false, default: 0
      t.boolean :active,      null: false, default: true
      t.timestamps
    end

    add_index :add_ons, :key, unique: true
  end
end
