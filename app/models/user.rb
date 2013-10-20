class User < ActiveRecord::Base
  validates_presence_of :email, :app_name, unless: :guest?
  validates_uniqueness_of :email, allow_blank: true

  has_secure_password(validations: false)
  validates_confirmation_of :password, if: lambda { |m| m.password.present? }, unless: :guest?
  validates_presence_of     :password, :on => :create, unless: :guest?
  validates_presence_of     :password_confirmation, if: lambda { |m| m.password.present? }, unless: :guest?
  before_create { raise "Password digest missing on new record" if password_digest.blank? && !guest? }

  has_many :components

  def name
    guest ? "Guest" : email
  end

  def self.new_guest
    new { |u| u.guest = true }
  end

  def move_to(user)
    # tasks.update_all(user_id: user.id)
  end
end
