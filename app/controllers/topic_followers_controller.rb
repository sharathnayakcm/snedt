class TopicFollowersController < ApplicationController
  before_filter :require_user
  before_filter :load_topic

  #Follow
  def create
    @topic.users << current_user
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "follower_block_#{@topic.id}", "<div id = 'unfollower_block_#{@topic.id}'><div class='redBtn '>#{link_to_remote(t(:unfollow),
            :url => topic_topic_follower_path(@topic, current_user),
            :method => :delete,
            :class => 'button')}</div></div>"
            page << "$j('#follow_count_#{@topic.id}').html('Followers : #{@topic.users.count}')"
        end
      }
    end
  end

  #Un follow
  def destroy
    @topic.users.delete(current_user)
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "unfollower_block_#{params[:topic_id]}","<div id = 'follower_block_#{params[:topic_id]}'><div class='greenBtn '>#{link_to_remote(t(:follow),
            :url => topic_topic_followers_path(@topic),
            :method => :post,
            :class => 'button')}</div></div>"
            page << "$j('#follow_count_#{@topic.id}').html('Followers :#{@topic.users.count}')"
        end
      }
    end

  end

  private

  def load_topic
    @topic = Topic.find(params[:topic_id])
  end

end
