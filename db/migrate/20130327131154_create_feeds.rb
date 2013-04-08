class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :name
      t.references :user

      t.timestamps
    end
    add_index :feeds, :user_id
  end
end
