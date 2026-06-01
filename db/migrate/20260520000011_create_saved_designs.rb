class CreateSavedDesigns < ActiveRecord::Migration[8.0]
  def change
    create_table :saved_designs do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :design, null: false, foreign_key: true
      t.timestamps
    end

    add_index :saved_designs, %i[user_id design_id], unique: true
  end
end
