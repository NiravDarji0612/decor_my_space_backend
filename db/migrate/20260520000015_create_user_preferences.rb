class CreateUserPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :user_preferences do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string  :locale,             null: false, default: "en"
      t.string  :currency,           null: false, default: "INR"
      t.boolean :dark_mode,          null: false, default: false
      t.boolean :location_services,  null: false, default: true
      t.boolean :notify_bookings,    null: false, default: true
      t.boolean :notify_promotions,  null: false, default: true
      t.boolean :notify_system,      null: false, default: true
      t.timestamps
    end
  end
end
