class AddAppNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :app_name, :string
  end
end
