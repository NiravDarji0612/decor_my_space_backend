class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :user,      null: false, foreign_key: true
      t.references :design,    null: false, foreign_key: true
      t.references :decorator, null: false, foreign_key: true

      t.integer :status,             null: false, default: 0
      t.string  :booking_reference,  null: false

      # Event
      t.string  :event_type,      null: false
      t.date    :event_date,      null: false
      t.string  :time_slot,       null: false
      t.integer :expected_guests, null: false, default: 0

      # Venue & contact
      t.string :venue_name,          null: false
      t.string :venue_address_line1, null: false
      t.string :venue_address_line2
      t.string :contact_full_name,   null: false
      t.string :contact_phone,       null: false
      t.string :contact_email,       null: false

      t.text   :special_instructions

      # Pricing (all in cents)
      t.integer :subtotal_cents,     null: false, default: 0
      t.integer :gst_cents,          null: false, default: 0
      t.integer :total_cents,        null: false, default: 0
      t.integer :advance_paid_cents, null: false, default: 0

      # Payment
      t.integer  :payment_method, null: false, default: 0
      t.integer  :payment_status, null: false, default: 0

      t.datetime :placed_on,           null: false
      t.datetime :cancelled_at
      t.string   :cancellation_reason

      t.timestamps
    end

    add_index :bookings, :booking_reference, unique: true
    add_index :bookings, :status
    add_index :bookings, :event_date
  end
end
