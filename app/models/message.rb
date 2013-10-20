class Message < ActiveRecord::Base
  STATUSES = {
    'Operational' => 0,
    'Partial Outage' => 1,
    'Major Outage' => 2
  }.freeze

  belongs_to :user

  validates_presence_of :message

  scope :in_order, -> { order("created_at DESC") }
end
