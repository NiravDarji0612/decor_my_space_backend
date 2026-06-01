class CreateBookingAddOns < ActiveRecord::Migration[8.0]
  def change
    create_table :booking_add_ons do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :add_on,  null: false, foreign_key: true
      t.integer    :price_cents, null: false, default: 0
      t.timestamps
    end

    add_index :booking_add_ons, %i[booking_id add_on_id], unique: true
  end
end
