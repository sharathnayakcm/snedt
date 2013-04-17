class Topic < ActiveRecord::Base
  attr_accessible :title
  has_one :asset, :as => :attachable
  has_many :streams
  has_many :activities
  has_and_belongs_to_many :users

  def user_follow?(user)
    self.users.exists?(user)
  end

  def points(current_user)
    self.activities.find(:all,:conditions => ["user_id = ?", current_user.id]).sum(&:points)    
  end
end
