class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :price
      t.text :description
      t.boolean :active

      t.timestamps
    end

    create_table :subscriptions do |t|
      t.references :user
      t.references :plan

      t.datetime :created_at
    end

    add_index :subscriptions, :user_id
    add_index :subscriptions, :plan_id
  end
end
