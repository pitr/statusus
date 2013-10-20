class User < ActiveRecord::Base
  validates_presence_of :email, :app_name, unless: :guest?
  validates_uniqueness_of :email, allow_blank: true
  validates_uniqueness_of :subdomain, allow_blank: true

  has_secure_password(validations: false)
  validates_confirmation_of :password, if: lambda { |m| m.password.present? }, unless: :guest?
  validates_presence_of     :password, :on => :create, unless: :guest?
  validates_presence_of     :password_confirmation, if: lambda { |m| m.password.present? }, unless: :guest?
  before_create { raise "Password digest missing on new record" if password_digest.blank? && !guest? }

  has_many :components
  has_many :messages

  def name
    guest ? "Guest" : email
  end

  def self.new_guest
    new { |u| u.guest = true }
  end

  def move_to(user)
    # components.update_all(user_id: user.id)
  end

  def populate_with_examples
    # components.create(name: 'API')
    # components.create(name: 'Admin')
    # components.create(name: 'Notifications')
  end

  def messages_for_public_page
    public_messages = messages.in_order.for_a_week.group_by(&:by_day)
    7.times do |i|
      time = i.days.ago
      public_messages[time.to_date] ||= [Message.new(text: "All is full of love", status: 0, created_at:time.end_of_day)]
    end
    public_messages
  end
end
