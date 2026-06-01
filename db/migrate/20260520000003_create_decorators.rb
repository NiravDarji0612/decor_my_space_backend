class CreateDecorators < ActiveRecord::Migration[8.0]
  def change
    create_table :decorators do |t|
      t.references :user, foreign_key: true, index: { unique: true }
      t.string  :name,             null: false
      t.string  :specialty
      t.string  :tagline
      t.text    :bio
      t.string  :avatar_url
      t.integer :hourly_rate_cents, null: false, default: 0
      t.integer :review_count,      null: false, default: 0
      t.decimal :rating_avg,        precision: 3, scale: 2, default: 0
      t.string  :area
      t.string  :city
      t.string  :phone
      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.boolean :active,    null: false, default: true
      t.timestamps
    end

    add_index :decorators, %i[city area]
    add_index :decorators, :rating_avg
  end
end
