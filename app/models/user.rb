class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me, :cname

  has_many :feeds
  has_many :subscriptions
  has_many :plans, through: :subscriptions

  before_create :set_uuid

  scope :active, -> { where(active: true) }

  def change_plan_to(plan)
    plans << Plan.where(name: plan).first!
  end

  private

  def set_uuid
    self.uuid = SecureRandom.uuid
  end

end
