class Message < ActiveRecord::Base
  STATUSES = {
    'Operational' => 0,
    'Partial Outage' => 1,
    'Major Outage' => 2
  }.freeze

  belongs_to :user, touch: true

  validates_presence_of :text

  scope :in_order, -> { order("created_at DESC") }
  scope :for_a_week, -> { where(:created_at => (7.days.ago.beginning_of_day..0.days.ago.end_of_day)) }

  def by_day
    created_at.to_date
  end

  def guid
    Digest::SHA1.hexdigest("Message:#{id}")
  end
end
