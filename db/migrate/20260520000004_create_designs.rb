class CreateDesigns < ActiveRecord::Migration[8.0]
  def change
    create_table :designs do |t|
      t.references :decorator, null: false, foreign_key: true
      t.references :category,  null: false, foreign_key: true
      t.string  :title,           null: false
      t.string  :subtitle
      t.text    :description
      t.integer :price_cents,     null: false, default: 0
      t.string  :currency,        null: false, default: "INR"
      t.decimal :rating_avg,      precision: 3, scale: 2, default: 0
      t.integer :review_count,    null: false, default: 0
      t.string  :hero_image_url
      t.boolean :available,       null: false, default: true
      t.boolean :featured,        null: false, default: false
      t.boolean :trending,        null: false, default: false
      t.integer :saved_count,     null: false, default: 0
      t.timestamps
    end

    add_index :designs, :featured
    add_index :designs, :trending
    add_index :designs, :available
    add_index :designs, :price_cents
  end
end
