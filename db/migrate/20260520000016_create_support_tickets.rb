class CreateSupportTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :support_tickets do |t|
      t.references :user, foreign_key: true
      t.string  :category, null: false
      t.string  :subject,  null: false
      t.text    :message,  null: false
      t.string  :email
      t.integer :status,   null: false, default: 0
      t.timestamps
    end

    add_index :support_tickets, :status
  end
end
