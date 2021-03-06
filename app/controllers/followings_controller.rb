class FollowingsController < ApplicationController
  before_filter :require_user
  before_filter :load_followings
  def index

  end

  def update_privacy_group
    users = []
    values = []
    if params[:commit] == "Save"
      unless @followings.blank?
        @followings.each do |user|
          users << "task_groups_" +user.id.to_s
          values << params["task_groups_" +user.id.to_s]
        end
        
        followers_pg = Hash.from_pairs_e(users,values)
        followers_pg.each do |follower,pgp|
          follower = follower.delete "task_groups_"
          PrivacyGroup.add_user_to_groups(pgp, follower)
          PrivacyGroup.remove_user_from_groups(pgp, follower, current_user)
        end
        render :update do |page|
          page << "notice('Added successfully into the group')"
        end
      else
        render :update do |page|
          page << "notice('You have no privacy groups to add')"
        end
      end
    end
  end

  def Hash.from_pairs_e(keys,values)
    hash = {}
    keys.size.times { |i| hash[ keys[i] ] = values[i] }
    hash
  end

  def streams
    @streams = current_user.followings_streams
    @no_post_panel = true
    @user_tabs = current_user.active_tabs
    @user_unused_tabs = current_user.unused_tabs
    @tab_name = "Followings"
    @custom_tab = current_user.custom_tabs.find_by_id(params[:id])
    (@custom_tab.blank?)?  @services = Service.all : @services = Service.find(:all, :conditions => ["id in (?)", @custom_tab.service_ids.to_s.split(',')])
    @stream_actions = current_user.read_or_create_stream_actions
    @show_popup = current_user.preferences.find_all_by_preference_id(1).length == 0
  end

  def follow
    Follower.follow(current_user.id, params[:following])
    current_user.followings.reload
    followers_count  = current_user.followers.count
    followings_count = current_user.followings.count
    friends_count = current_user.friends.count
    render :update do |page|
      page.replace_html "action_1_#{params[:following]}", link_to_remote('Unfollow',
        :url => unfollow_followings_path(:following => params[:following]),
        :html => {:class => 'button'})
      page << "$j('#followers_list_count').html(#{followers_count - friends_count})"
      page << "$j('#followings_list_count').html(#{followings_count - friends_count + current_user.company_followers.count.to_i})"
      page << "$j('#friends_list_count').html(#{friends_count})"
      page << "$j('.follower_heading').html('You have #{followings_count - friends_count} Following(s)!')"
      page << "$j('.no_users').html('You have #{followings_count - friends_count} followings')"
      page << "$j('#following_list_#{params[:following]}').show();"
    end
  end

  def unfollow
    Follower.unfollow(current_user.id, params[:following])
    current_user.followings.reload
    followers_count  = current_user.followers.count
    followings_count = current_user.followings.count
    friends_count = current_user.friends.count

    render :update do |page|
      page.replace_html "action_1_#{params[:following]}", link_to_remote('Follow', :url => follow_followings_path(:following => params[:following]), :html => {:class => 'button'})
      page << "$j('#followers_list_count').html(#{followers_count - friends_count})"
      page << "$j('#followings_list_count').html(#{followings_count - friends_count  + current_user.company_followers.count.to_i})"
      page << "$j('#friends_list_count').html(#{friends_count})"
      page << "$j('.no_users').html('You have #{followings_count - friends_count} followings')"
      page << "$j('.follower_heading').html('You have #{followings_count - friends_count} Following(s)!')"
    end
  end

    def followings_filter_custom_streams
    @custom_tab = current_user.custom_tabs.find_by_id(params[:id])
    @streams = current_user.followings_streams
    @filter = true
    @by = params[:by]
    @service_id = params[:service_id]
    @stream_actions = current_user.read_or_create_stream_actions
    if params[:by]
      if params[:by] == "all"
        @streams = @streams.paginate(:per_page => 25, :page => params[:page] || 1)
      elsif params[:by] == "read"
        read_streams = @streams.select {|x| (x.is_read == true and x.is_deleted == nil) and x.message_type_id != 8 }
        @streams = read_streams.paginate(:per_page => 25, :page => params[:page] || 1) unless read_streams.blank?
      elsif params[:by] == "unread"
        unread_streams = @streams.select {|x| (x.is_read == false and x.is_deleted == nil) and x.message_type_id != 8 }
        @streams = unread_streams.paginate(:per_page => 25, :page => params[:page] || 1) unless unread_streams.blank?
      elsif params[:by] == "favourites"
        favourites = @streams & current_user.favourites
        @streams = favourites.paginate(:per_page => 25, :page => params[:page] || 1) unless favourites.blank?
      elsif params[:by] == "edintity"
        edintity = current_user.followings_edintity_streams
        @streams = edintity.paginate(:per_page => 25, :page => params[:page] || 1) unless edintity.blank?
      end
    else
      service_streams = @streams.select {|x| (x.service_id == params[:service_id].to_i and x.is_deleted == nil) and x.message_type_id != 8 }
      @streams = service_streams.paginate(:per_page => 25, :page => params[:page] || 1)
    end
    render :update do |page|
      page.replace_html "stream_content", :partial => "streams/index"
      page << "$j('#stream_content').show();"
    end
 end
  def more_streams
    get_more_streams(params,current_user)
    render :update do |page|
      page.insert_html :bottom, 'stream_content', :partial => "streams/more_streams", :locals => {:streams => @streams, :current_page => params[:current_page].to_i}
      page << "$j('.auto-submit-star').rating();"
    end
  end

  private

  def load_followings
    @followings = current_user.get_followings
    @company_followings = current_user.company_followers
    @followers = current_user.get_followers
    @friends = current_user.friends
    @post_types = PostType.find(:all)
    @privacy_groups = current_user.privacy_groups
  end


end
