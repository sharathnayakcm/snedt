class SideBarController < ApplicationController
  layout "application"
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def index
  end

 
  def Hash.from_pairs_e(keys,values)
    hash = {}
    keys.size.times { |i| hash[ keys[i] ] = values[i] }
    hash
  end

  def friends_list
    @privacy_group_count = current_user.privacy_groups.count
    @friend_ids = Follower.friends(current_user)
    @friends =  User.find(:all, :conditions => " id in (#{@friend_ids.join(",")})") unless @friend_ids.blank?
    @post_service_groups = current_user.post_service_groups
    users = []
    values = []
    if params[:commit] == "Save"
      unless @friends.blank?
        @friends.each do |user|
          users << "task_groups_" +user.id.to_s
          values << params["task_groups_" +user.id.to_s]
        end
        followers_pg = Hash.from_pairs_e(users,values)
        followers_pg.each do |follower,pgp|
          follower = follower.delete "task_groups_"
          add_user_to_groups(pgp, follower)
          remove_user_from_groups(pgp, follower)
        end
        render :update do |page|
          page << "notice('Added successfully into the group')"
        end
      end
    end
  end

  
  
  def toggle_follow
    # Follow a particular follower
    if params[:id] == "follow"
      @follower = Follower.create(:user_id => current_user.id, :follower_id => params[:follower])
      @follower.save
      followers_count  = Follower.followings(current_user).count
      followings_count = Follower.followers(current_user).count
      friends_count = Follower.friends(current_user).count
      render :update do |page|
        page.replace "follow_#{params[:follower]}", :inline => "<td id='unfollow_#{params[:follower]}'><%= link_to_remote 'Unfollow',
  :url => {:action => 'toggle_follow' ,:id => 'unfollow', :follower => params[:follower]},
  :html => {:id => 'unfollow', :class => 'button'} %></td>"
        page << "$j('.followers_list_count').html(#{followers_count})"
        page << "$j('.followings_list_count').html(#{followings_count})"
        page << "$j('.friends_list_count').html(#{friends_count})"
      end
    elsif params[:id] == "unfollow"
      if (params[:type] == "follower") || (params[:type] == "friend")
        @following = Follower.find_by_follower_id_and_user_id(params[:follower],current_user.id)
        @following.destroy if @following
      else
        @follower = Follower.find_by_user_id_and_follower_id(current_user.id,params[:follower])
        @follower.destroy
      end
      followers_count  = Follower.followings(current_user).count
      followings_count = Follower.followers(current_user).count
      friends_count = Follower.friends(current_user).count
      render :update do |page|
        page.replace "unfollow_#{params[:follower]}", :inline => "<td id='follow_#{params[:follower]}'><%= link_to_remote 'Follow',
  :url => {:action => 'toggle_follow' ,:id => 'follow',:follower => params[:follower]},
  :html => {:id => 'follow', :class => 'button'} %></td>"
        page << "$j('.followers_list_count').html(#{followers_count})"
        page << "$j('.followings_list_count').html(#{followings_count})"
        page << "$j('.friends_list_count').html(#{friends_count})"
      end
    end
  end

  def toggle_block
    # Block a particular follower
    user = User.find(params[:follower]) # Follower can be follower user/following user/friend user
    user.toggle!(:is_blocked) if user
    render :update do |page|
      page.replace_html "block_#{params[:follower]}", link_to_remote( user.is_blocked ? 'Unblock' : "Block",
        :url => {:action => 'toggle_block' ,:id => 'unblock', :follower => params[:follower]}, :html => { :class => "button" })
    end
  end

  def is_followed?(follower)
    
    
  end

end


