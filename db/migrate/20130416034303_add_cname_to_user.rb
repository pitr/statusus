class AddCnameToUser < ActiveRecord::Migration
  def change
    add_column :users, :cname, :string
    add_index :users, :cname
  end
end
