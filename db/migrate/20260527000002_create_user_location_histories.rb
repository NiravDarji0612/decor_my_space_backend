class CreateUserLocationHistories < ActiveRecord::Migration[8.0]
  # Optional, append-only audit trail for user locations. Designed to be
  # extensible (source, accuracy, etc.) without touching the hot users table.
  def change
    create_table :user_location_histories do |t|
      t.references :user,      null: false, foreign_key: true, index: true
      t.decimal    :latitude,  precision: 10, scale: 6, null: false
      t.decimal    :longitude, precision: 10, scale: 6, null: false
      t.float      :accuracy_m
      t.string     :source, default: "client", null: false
      t.datetime   :recorded_at, null: false
      t.timestamps
    end

    add_index :user_location_histories, %i[user_id recorded_at]
  end
end
