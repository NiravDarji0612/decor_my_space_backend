class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string  :slug,        null: false
      t.string  :title,       null: false
      t.string  :icon_key
      t.string  :tint_hex
      t.string  :icon_color_hex
      t.string  :cover_url
      t.jsonb   :match_keys,  null: false, default: []
      t.integer :position,    null: false, default: 0
      t.boolean :active,      null: false, default: true
      t.timestamps
    end

    add_index :categories, :slug, unique: true
    add_index :categories, :position
    add_index :categories, :match_keys, using: :gin
  end
end
