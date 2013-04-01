class Feed < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :resolved
  has_many :messages, order: 'created_at DESC'

  def resolved
    messages.first ? messages.first.resolved : true
  end
end