class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :body
      t.boolean :resolved
      t.references :feed

      t.timestamps
    end
    add_index :messages, :feed_id
  end
end
