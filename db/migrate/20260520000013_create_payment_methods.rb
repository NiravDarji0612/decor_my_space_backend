class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_methods do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :kind,     null: false, default: 0
      t.string  :title,    null: false
      t.string  :subtitle
      t.string  :last4
      t.string  :provider_token
      t.date    :expires_on
      t.boolean :is_default, null: false, default: false
      t.timestamps
    end

    add_index :payment_methods, %i[user_id is_default]
  end
end
