class Message < ActiveRecord::Base
  belongs_to :feed
  attr_accessible :body, :resolved
end
