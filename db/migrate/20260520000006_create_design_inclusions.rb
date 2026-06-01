class CreateDesignInclusions < ActiveRecord::Migration[8.0]
  def change
    create_table :design_inclusions do |t|
      t.references :design, null: false, foreign_key: true
      t.string  :label,    null: false
      t.string  :icon_key
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :design_inclusions, %i[design_id position]
  end
end
