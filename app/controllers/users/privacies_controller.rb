class Users::PrivaciesController < ApplicationController
#  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user
  def new
    @privacytypes = PrivacyType.find(:all).map{|s| [s.name,s.id]}
    @privacy_setting = current_user.read_or_create_privacy_setting
    current_user.read_or_create_stream_actions
  end

  def edit
    @privacytypes = PrivacyType.find(:all).map{|s| [s.name,s.id]}
  end

  def create
    @user = current_user
    @user.update_attributes(:status => "4")
    #TODO Save the privacy details
    redirect_to "/users/done"
  end

  def edit_privacy
    current_user.update_attributes(params[:privacy_settings])
    flash[:notice] = "Privacy settings updated successfully!"
  end

  def update
    current_user.active_services.all.each do |user_service|
      user_service.default_stream_action.update_attributes({:allow_comments => params[:allow_comments][user_service.id.to_s],:favourite => params[:favourite][user_service.id.to_s]})
      user_service.update_attributes({:privacy_type_id => params[:user_privacy_setting][user_service.id.to_s]})
    end
    current_user.user_privacy_setting.update_attributes({:profile => params[:user_privacy_setting][:profile], :stream => params[:user_privacy_setting][:edintity], :is_searchable => params[:user_privacy_setting][:is_searchable]})
    current_user.default_stream_action.update_attributes({:allow_comments => params[:allow_comments][:edintity],:favourite => params[:favourite][:edintity]})
    current_user.update_attributes({:friends_find => params[:user_privacy_setting][:friends_find] ? true : false})
    render :update do |page|
#      page << "$j('#privacy_spinner_tag').hide();"
      page << "notice('Privacy settings successfully updated')"
    end
  end

  def blocked_users
    @blocked_users = current_user.blocked_users
  end

  def update_stream_actions
    current_user.default_stream_action.update_attributes({:allow_comments => !params[:allow_comments].blank?, :review => !params[:review].blank?,:retweet => !params[:retweet].blank?,:favourite => !params[:favourite].blank?})
    render :update do |page|
      page << "notice('#{t :profile_updated}')"
    end
  end

  
  def toggle_block
    # Block a particular follower
    user = BlockedUser.find(params[:user]) # Follower can be follower user/following user/friend user
    user.toggle!(:is_blocked) if user
    render :update do |page|
      page.replace_html "block_#{params[:user]}", link_to_remote( user.is_blocked ? 'Unblock' : "Block",
        :url => {:action => 'toggle_block' ,:id => 'unblock', :user => params[:user]}, :html => { :class => "button" })
    end
  end

end
