class ActivitiesController < ApplicationController
  before_filter :require_user
  def index
    @activities = current_user.activities.find(:all, :order => "created_at DESC")
    @total_points = 0
    @activities.each do |activity|
      @total_points += activity.points
    end
  end
end
