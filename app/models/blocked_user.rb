class BlockedUser < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :blocked_user_id, :scope => [:user_id]

  def self.block(blocking_user, blocked_user)
    BlockedUser.create(:user_id => blocking_user, :blocked_user_id => blocked_user)
  end

  def self.unblock(blocking_user, blocked_user)
    blocked_user = BlockedUser.find_by_user_id_and_blocked_user_id(blocking_user, blocked_user)
    unless blocked_user.blank?
    blocked_user.destroy 
    blocked_user
    end
  end

  def blocked
    User.find_by_id(self.blocked_user_id)
  end
end
