class Component < ActiveRecord::Base
  STATUSES = {
    'Operational' => 0,
    'Partial Outage' => 1,
    'Major Outage' => 2
  }.freeze

  belongs_to :user

  validates_presence_of :name
end
