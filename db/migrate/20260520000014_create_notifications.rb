class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :title, null: false
      t.text    :body
      t.integer :kind,  null: false, default: 0
      t.jsonb   :payload, null: false, default: {}
      t.datetime :read_at
      t.datetime :delivered_at
      t.timestamps
    end

    add_index :notifications, %i[user_id read_at]
    add_index :notifications, :kind
  end
end
