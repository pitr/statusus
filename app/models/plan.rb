class Plan < ActiveRecord::Base
  # attr_accessible :description, :name, :price, :active

  has_many :subscriptions
  has_many :users, through: :subscriptions
end
