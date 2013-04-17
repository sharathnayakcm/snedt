class ProfilesController < ApplicationController
  layout "application"
  before_filter :require_user, :except => [:index, :more_streams]

  def index
    per_page = 10
    @user = User.find_by_user_name_and_active(params[:id], 1)
    if @user
      if(@user && can_view_profile(current_user, @user)== true)
        if @user == current_user
          @streams = current_user.streams.displayed.paginate(:page => 1, :per_page => per_page)
          RssLink.get_feeds(current_user)
          get_rss_feeds(current_user)
        else
          @streams = Stream.displayed_streams(@user, current_user).paginate(:page => 1, :per_page => per_page)
          RssLink.get_feeds(@user)
          get_rss_feeds(@user)
        end
        unless @rss_streams.blank?
          @rss_streams.each do |st|
            @streams<< st
          end
        end
        @stream_actions = @user.read_or_create_stream_actions
        @background_attributres = StyleAttribute.background
        @font_attributres = StyleAttribute.font
        @panel_types = PanelType.all
        @skin_styles = {}
        @skin = @user.active_skin
        @default_skin = Skin.edintity_default
        @my_skins = current_user.skins if current_user
        @applying_skin = params[:apply_skin] ? true : false
        @skin = Skin.edintity_default if @skin.blank?
        if !@skin.blank? && !@skin.skin_styles.blank?
          style_ids = []
          @skin.skin_styles.each do |style|
            style_ids << style.id
            element_name = "#{PanelType::TYPE_NAMES[style.panel_type_id]}_#{StyleAttribute::TYPE_NAMES[style.style_attribute_id]}"
            element_value = style.attribute_value
            @skin_styles[element_name] = element_value
          end
          @user_background_imges = Asset.find(:all, :conditions => ["attachable_type = 'SkinStyle' and attachable_id in (?)", style_ids]) unless style_ids.blank?
        end
        #          s= Skin.find(1)
        #      ss = Notification.all
        #      ss.each_with_index do |a, idx|
        #        p "#{idx+1}:"
        #        Notification.column_names.each do |nm|
        #          p "  #{nm}: #{a.read_attribute(nm)}"
        #        end
        #        p ""
        #      end
      else
        flash[:notice] = "#{t(:user_profile_blocked)}"
        redirect_to root_url
      end
    else
      flash[:notice] = "#{t(:user_not_exist_or_not_active)}"
      redirect_to root_url
    end
  end

  def follow
    follower = User.find_by_id(params[:id])
    if follower
      Follower.follow(current_user.id, params[:id])
      if params[:scope] == "search"
        render :update do |page|
          page.replace_html "user_follow_unfollow_#{follower.id}", link_to_remote_with_loader("#{t :unfollow}", {:url => unfollow_user_friends_path(current_user, :follower => follower.id, :scope => "search"), :method => :get}, :class => "smlrBtn")
          page << "$j('#user_follow_unfollow_#{follower.id}').removeClass('blueBtn');$j('#user_follow_unfollow_#{follower.id}').addClass('yellowBtn');"
        end
      else
        render :update do |page|
          page.replace_html "follow_unfollow_btn", link_to_remote('Unfollow',
            :url => "/profiles/unfollow/#{params[:id]}")
          page << "$j('#user_follow_unfollow_#{follower.id}').removeClass('blueBtn');$j('#user_follow_unfollow_#{follower.id}').addClass('yellowBtn');"
          page << "notice('You are now following #{follower.user_name}')"
        end
      end
    end
  end

  def unfollow
    follower = User.find_by_id(params[:id])
    if follower
      Follower.unfollow(current_user.id, params[:id])
      render :update do |page|
        page.replace_html "follow_unfollow_btn", link_to_remote('Follow',
          :url => "/profiles/follow/#{params[:id]}")
        page << "notice('You are no longer following #{follower.user_name}')"
      end
    end
  end

  def report_as_spammer
    spammer = User.find_by_id(params[:id])
    if spammer
      already_reported = current_user.reported_as_spammer(spammer)
      unless already_reported
        SpammedUser.create(:user_id => params[:id], :spammed_by_id => current_user.id, :description => params[:description])
      end
      @user = spammer
      render :update do |page|
        page << "notice('You have reported #{spammer.user_name} as spammer')"
        page.replace_html "spammer_link", :partial => "undo_spammer"
      end
    end
  end

  def undo_spammer
    spammer = User.find_by_id(params[:id])
    if spammer
      already_reported = current_user.reported_as_spammer(spammer)
      if already_reported && already_reported.revealed_at.blank?
        already_reported.delete
      end
      @user = spammer
      render :update do |page|
        page << "notice('You have marked #{spammer.user_name} as not a spammer')"
        page.replace_html "spammer_link", :partial => "report_spammer"
      end
    end
  end

  def more_streams
    per_page = 10
    @user = User.find_by_id(params[:user])
    if @user
      if @user == current_user
        @streams = current_user.streams.displayed.paginate(:page => params[:current_page], :per_page => per_page)
      else
        @streams = Stream.displayed_streams(@user, current_user).paginate(:page => params[:current_page], :per_page => per_page)
      end
      render :update do |page|
        page.insert_html :bottom, 'stream_content', :partial => "profiles/more_streams", :locals => {:streams => @streams, :current_page => params[:current_page].to_i}
        page << "$j('.auto-submit-star').rating();"
      end
    end
  end

  def apply_skin
    current_user.update_attribute(:active_skin_id, params[:skin_id])
    redirect_to :controller => :profiles, :id => current_user.user_name, :apply_skin => true
  end

  def followers
    @user = User.find_by_id(params[:id])
    if @user
      @followers = @user.get_followers - @user.friends
    end

  end

  def followings
    @user = User.find_by_id(params[:id])
    if @user
      @followings = @user.get_followings - @user.friends
#      render :update do |page|
#        page << "$j('.text_following').addClass('selected_tab');$j('.text_followers,.text_friends').removeClass('selected_tab')"
#        page.replace_html "stream_content", :partial => "followings"
#      end
    end
  end

  def friends
    @user = User.find_by_id(params[:id])
    if @user
      @friends = @user.friends
#      render :update do |page|
#        page << "$j('.text_friends').addClass('selected_tab');$j('.text_followers,.text_following').removeClass('selected_tab')"
#        page.replace_html "stream_content", :partial => "friends"
#      end
    end
  end

  def show_stream
    @stream = Stream.find_by_id(params[:id])
    unless @stream.blank?
      @user = @stream.user
      @can_be_viewed = @stream.user == current_user || @stream.can_be_viewed(current_user)
    end
  end

  private

  def can_view_profile(user, profile_user)
    unless user.blank?
      blocked = BlockedUser.find_by_user_id_and_blocked_user_id( profile_user.id,user.id)
      return !(blocked.blank?)? false : true
    else
      return true
    end
  end

  def get_rss_feeds(user)
    streams = []
    @unread_items = 0
    user.rss_links.each do |link|
      streams += link.streams.displayed_rss
      @unread_items += link.streams.unread_items_rss.count
    end
    @rss_streams = streams.paginate(:page => 1, :per_page => 10)
  end
  
end
