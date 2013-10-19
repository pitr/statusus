class User < ActiveRecord::Base
  validates_presence_of :username, :email, unless: :guest?
  validates_uniqueness_of :username, allow_blank: true

  has_secure_password(validations: false)
  validates_confirmation_of :password, if: lambda { |m| m.password.present? }, unless: :guest?
  validates_presence_of     :password, :on => :create, unless: :guest?
  validates_presence_of     :password_confirmation, if: lambda { |m| m.password.present? }, unless: :guest?
  before_create { raise "Password digest missing on new record" if password_digest.blank? && !guest? }

  def name
    guest ? "Guest" : username
  end

  def self.new_guest
    new { |u| u.guest = true }
  end

  def move_to(user)
    # tasks.update_all(user_id: user.id)
  end
end
