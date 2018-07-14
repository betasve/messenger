class AddMessages < ActiveRecord::Migration[5.1]
  def up
    create_table :messages do |t|
      t.integer :message_type, null: false, index: true
      t.string :payload, null: false, limit: 160

      t.datetime :created_at, null: false
    end
  end

  def down
    drop_table :messages
  end
end
