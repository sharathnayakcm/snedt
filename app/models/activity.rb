class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  belongs_to :action_user, :foreign_key => :action_user_id, :class_name => "User"

  ACTIVITY_TYPES = {
    :post_to_topic => 1,
    :share => 2,
    :favorite => 3,
    :comment => 4,
    :flag => 5,
    :shared => 6,
    :favorited => 7,
    :commented => 8,
    :flagged => 9,
    :invite => 10,
    :activate => 11
  }

  ACTIVITY_POINTS = {
    1 => 5,
    2 => 8,
    3 => 3,
    4 => 5,
    5 => 0,
    6 => 8,
    7 => 3,
    8 => 5,
    9 => -3,
    10 => 4,
    11 => 10
  }

  ACTIVITY_DAILY_LIMIT = {
    6 => 5,
    7 => 10,
    8 => 5
  }

  DAILY_LIMIT = 250

  def self.add_points(user, activity_type, actionable_type, actionable_id, action_user_id = nil, topic_id = nil)
    if !daily_limit_reached(user, activity_type) && !activity_limit_reached(user, activity_type)
      activity = user.activities.new
      activity.activity_type = activity_type
      activity.actionable_type = actionable_type
      activity.actionable_id = actionable_id
      activity.action_user_id = action_user_id
      activity.topic_id = topic_id
      activity.save
    end
  end

  def self.activity_limit_reached(user, activity_type)
    activity_points = user.activities.find(:all, :conditions => ["activity_type = ? and Date(created_at) = ?", activity_type, Date.today.strftime("%Y-%m-%d")]).length
    if ACTIVITY_DAILY_LIMIT[activity_type]
      activity_points >= ACTIVITY_DAILY_LIMIT[activity_type]
    else
      false
    end
  end

  def self.daily_limit_reached(user, activity_type)
    total_points = 0
    user.activities.find(:all, :conditions => ["Date(created_at) = ?", Date.today.strftime("%Y-%m-%d")]).each do |activity|
      total_points += ACTIVITY_POINTS[activity.activity_type]
    end
    total_points += ACTIVITY_POINTS[activity_type]
    total_points > DAILY_LIMIT
  end

  def points
    ACTIVITY_POINTS[activity_type]
  end
end
