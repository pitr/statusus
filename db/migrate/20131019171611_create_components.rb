class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.references :user, index: true
      t.string :name
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
