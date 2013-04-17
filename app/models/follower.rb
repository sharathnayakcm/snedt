class Follower < ActiveRecord::Base
  #Associations
  belongs_to :user
  belongs_to :friend, :foreign_key => "follower_id", :class_name => "User"
  belongs_to :following_user, :class_name => "User", :foreign_key => "follower_id"


  def self.follow(user_id, follower_id)
    follower = Follower.find_by_user_id_and_follower_id(follower_id, user_id)
    if follower.blank?
      follower = Follower.create(:user_id => follower_id, :follower_id => user_id)
      if follower.save && follower.user.is_notifiable?("Follows")
        image_url = follower.user.profile_image.blank? ? "/avatars/original/missing.png" : follower.user.profile_image.asset.url.gsub("/s3.","/s3-eu-west-1.")
        Notification.deliver_notification("Follows", follower.user, { "params" => {"image_url" => image_url, "profile_url" => "/profiles/#{follower.following_user.user_name}", "user_name" => follower.following_user.full_name}})
      end
    end
    follower.reload
  end

  def self.unfollow(user_id, follower_id)
    follower = Follower.find(:first, :conditions => ["user_id = ? and follower_id = ?", follower_id, user_id ])
    unless follower.blank?
      follower.destroy
    end
  end

  # My Followings
  def self.followings(current_user)
    get_followings(current_user)
    get_followers(current_user)
    @following_ids - @followers_ids
  end

  # My Followers
  def self.followers(current_user)
    get_followers(current_user)
    get_followings(current_user)
    @followers_ids - @following_ids
  end

  #  def self.followers_followings(current_user)
  #    followers(current_user).concat(followings(current_user))
  #  end
  #
  #  def self.followers_friends(current_user)
  #   followers(current_user).concat(friends(current_user))
  #  end
  #
  #  def self.followings_friends(current_user)
  #    followings(current_user).concat(friends(current_user))
  #  end
  
  # My Friends
  def self.friends(current_user)
    get_followings(current_user)
    get_followers(current_user)
    followings = @following_ids
    followers = @followers_ids
    (followings) & (followers)
  end




  # By User Name
  #  def self.display_with_user_name(name)
  #    User.find_by_user_name(name)
  #  end
  #  # Followers & UName
  #  def followers_username(user,name)
  #    username = User.find_by_user_name(name)
  #    followers(user).concat(username.id)
  #  end
  
  def self.get_followers(current_user)
    my_followers = current_user.followers.find(:all, :include => [:friend], :conditions => ["users.active=1"])
    @followers_ids = []
    my_followers.each do |follower|
      @followers_ids << follower.follower_id
    end
  
  end
  
  def self.get_followings(current_user)
    my_followings = Follower.find(:all, :include => ["user"],:conditions => "users.active = '1' and follower_id = #{current_user.id}")
    @following_ids = []
    my_followings.each do |following|
      @following_ids << following.user_id
    end
  end

  
end
