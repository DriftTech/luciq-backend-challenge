class CreateApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :applications do |t|
      t.string :name
      t.string :token
      t.integer :chats_count, null: false, default: 0

      t.timestamps
    end
    add_index :applications, :token
  end
end
