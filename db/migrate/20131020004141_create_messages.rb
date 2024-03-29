class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :user, index: true
      t.string :text
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
