class CreateDesignImages < ActiveRecord::Migration[8.0]
  def change
    create_table :design_images do |t|
      t.references :design, null: false, foreign_key: true
      t.string  :url,      null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :design_images, %i[design_id position]
  end
end
