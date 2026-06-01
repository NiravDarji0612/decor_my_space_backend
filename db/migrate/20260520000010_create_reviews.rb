class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :booking,   null: false, foreign_key: true, index: { unique: true }
      t.references :user,      null: false, foreign_key: true
      t.references :decorator, null: false, foreign_key: true
      t.references :design,    null: false, foreign_key: true

      t.integer :rating,           null: false
      t.text    :comment
      t.jsonb   :tags,             null: false, default: []
      t.boolean :would_recommend,  null: false, default: true
      t.timestamps
    end

    add_index :reviews, :rating
  end
end
