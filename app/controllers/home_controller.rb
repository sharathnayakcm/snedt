class HomeController < ApplicationController
  layout "application"
  before_filter :require_user, :only => [:index, :add_new_tab]
  require 'twitter_oauth'
  include TwitsHelper
  include TumblrHelper
  include HomeHelper

  def index
    load_instances(false)
    streams = if request.path.inspect.index("social_inbox")
       params[:tag_name].present? ? Stream.edintity_and_topic_streams(@current_user,"",params[:tag_name]) : @current_user.streams.from_services
    else
      Stream.edintity_and_topic_streams(@current_user, params[:topic_id],params[:tag_name])
    end
    session[:stream_count] = streams.count
    @streams = streams.paginate(:page => 1, :per_page => 10)
  end


  #TODO Code to be reviewed
  def get_streams
    partial_path = "streams/unread_items"
    if params[:scope] == "brands" || params[:scope] == "companies"
      partial_path = "streams/brands/unread_items"
      @brand = Brand.find(params[:brand_id])
      brand = @brand
      if params[:scope] == "companies"
        brand = @brand.company
      end
      get_company_feeds_from_services(brand)
      @stream_count = brand.streams.not_displayed_for_brands.count #if @no_post_panel.blank?
      @unread_items = brand.streams.unread_items.count
    else
      get_feeds_from_services
      @stream_count = current_user.streams.not_displayed.count if @no_post_panel.blank?
      @unread_items = current_user.streams.unread_items.count
    end
    if params[:is_in_play_mode] == "true"
      redirect_to :controller => :streams, :action => :get_stream_from_db
    else
      render :update do |page|
        page.replace_html "socialInboxIco", "Social Inbox (#{@stream_count})" if @stream_count > 0 && params[:stream_type] != 'social_inbox'
        #        page.replace_html "unread_items_count", :partial => partial_path, :locals => {:current_user => current_user}
      end
    end
  end
  #end


  def get_topic_count
    streams =  Stream.edintity_and_topic_streams(@current_user)
    @stream_count = streams.count - session[:stream_count]
    render :update do |page|
      page.replace_html "myStreamIco", "Home (#{@stream_count})" if @stream_count > 0
      page << "$j('#new_post_update').show()" if @stream_count > 0
    end
  end


  def load_post_stream_form
    @upload_setting = UploadSetting.first
    if params[:type] == "Photo"
      form = "posts/post_photo"
    elsif params[:type] == "Link"
      form = "posts/post_link"
    elsif params[:type] == "Blog"
      form = "posts/post_blog"
    elsif params[:type] == "Video"
      form = "posts/post_video"
    else
      form = "posts/status_update"
    end
    render :update do |page|
      page.replace_html 'status_update', :partial => form
      page << "$j('#stream_extras').hide()"
      page << "$j('#stream_upload').hide()"
      page << "$j('#stream_upload_video').hide()"
      page << "$j('#share_photo_to_services_extras').hide();"
      page << "$j('#share_video_to_services_extras').hide();"
      page << "$j('#share_blog_to_services_extras').hide();"
      page << "$j('#share_to_services_extras').hide();"
      page << "$j('#share_status_to_services_extras').hide();"
      page << "$j('.post_photo').corner('top');"
      page << "$j('.video_footer').corner('bottom 5px');"
      page << "$j('.star').rating();"
      if params[:type] == "Photo"
        page << "showUploadButton();"
      elsif params[:type] == "Video"
        page << "showUploadButtonVideo();"
      end
    end
  end

  def load_share_service_for_brand
    @brand = Brand.find_by_id(params[:brand])
    if params[:type] == "Photo"
      replace = "share_photo_to_services_extras"
      with_partial = "companies/services/share_photo_to_services"
    elsif params[:type] == "Link"
      replace = "share_to_services_extras"
      with_partial = "companies/services/share_to_services"
    elsif params[:type] == "Blog"
      replace = "share_blog_to_services_extras"
      with_partial = "companies/services/share_blog_to_services"
    elsif params[:type] == "Video"
      replace = "share_video_to_services_extras"
      with_partial = "companies/services/share_video_to_services"
    else
      replace = "share_status_to_services_extras"
      with_partial = "companies/services/share_status_to_services"
    end
    render :update do |page|
      page.replace_html replace, :partial => with_partial
    end
  end

  def more_streams
    per_page = 10
    @stream_actions = current_user.read_or_create_stream_actions
    unless params[:tab_name].blank?
      @custom_tab = current_user.custom_tabs.find_by_name(params[:tab_name])
      @streams = current_user.custom_streams(@custom_tab) unless @custom_tab.blank?
    end
    if params[:search_filter]
      @streams = current_user.custom_streams(@custom_tab)
      @streams = @streams.paginate(:per_page => 1, :page => params[:current_page])
    elsif params[:filter]
      if params[:by]
        if params[:by] == "all"
          @streams = current_user.streams.displayed.paginate(:page => params[:current_page], :per_page => per_page)
        elsif params[:by] == "read"
          @streams = current_user.streams.read_items.paginate(:page => params[:current_page], :per_page => per_page)
        elsif params[:by] == "unread"
          @streams = current_user.streams.unread_items.paginate(:page => params[:current_page], :per_page => per_page)
        elsif params[:by] == "favourites"
          @streams = current_user.favourites.paginate(:page => params[:current_page], :per_page => per_page)
        elsif params[:by] == "edintity"
          edintity = current_user.streams.edintity_streams
          @streams = edintity.paginate(:per_page => per_page, :page => params[:page] || 1) unless edintity.blank?
        end
      else
        @streams = @current_user.streams.send(params[:stream_type]== "social_inbox" ? "from_services" : "edintity_streams").find(:all, :conditions => "service_id = #{params[:service_id]}").paginate(:page => params[:current_page], :per_page => per_page)
      end
    else
      if params[:tab_name]
        @stream_header = params[:tab_name]
        # @streams = current_user.send("#{params[:tab_name]}_streams").paginate(:page => params[:current_page], :per_page => 25)
        @streams = current_user.custom_streams(@custom_tab).paginate(:page => params[:current_page], :per_page => per_page)
      else
        @streams = @current_user.streams.send(params[:stream_type]== "social_inbox" ? "from_services" : "edintity_streams").paginate(:page => params[:current_page], :per_page => per_page)
      end
    end
    render :update do |page|
      page.insert_html :bottom, 'stream_content', :partial => "streams/more_streams", :locals => {:streams => @streams, :current_page => params[:current_page].to_i}
      page << "$j('.auto-submit-star').rating();"
    end
  end

  def rate_stream
    @stream = Stream.find(params[:id])
    @stream.star_count = params['star_'+params['id']]
    @stream.save
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page << "$j('.auto-submit-star').rating();"
        end
      }
    end
  end

  def rss_reader
    redirect_to :controller => :rss, :action => :show, :id => params[:id]
  end

  def display_with_user_name(name)
    username = User.find_by_user_name(name)
    redirect_to  :action => "index", :with_username => username
  end

  def display_custom_streams
    @header = "Create Custom Tab"
    @custom_tab = current_user.custom_tabs.find_by_id(params[:id])
    @no_post_panel = true
    unless @custom_tab.blank?
      @stream_header = @custom_tab.name.to_s.upcase
    end
    load_instances(false)
    @streams = current_user.custom_streams(@custom_tab)
    (@custom_tab.blank?)?  @services = Service.all : @services = Service.find(:all, :conditions => ["id in (?)", @custom_tab.service_ids.to_s.split(',')])
    @tab_name = @custom_tab.name
    render :index
  end

  def filter_custom_streams
    per_page = 10
    @custom_tab = current_user.custom_tabs.find_by_id(params[:id])
    @streams = current_user.custom_streams(@custom_tab)
    @filter = true
    @by = params[:by]
    @service_id = params[:service_id]
    @stream_actions = current_user.read_or_create_stream_actions
    #TODO: Move all the queries to model
    if params[:by]
      if params[:by] == "all"
        @streams = @streams.paginate(:per_page => per_page, :page => params[:page] || 1)
      elsif params[:by] == "read"
        read_streams = @streams.select {|x| (x.is_read == true and x.is_deleted == nil) and x.message_type_id != 8 }
        @streams = read_streams.paginate(:per_page => per_page, :page => params[:page] || 1)
      elsif params[:by] == "unread"
        unread_streams = @streams.select {|x| (x.is_read == false and x.is_deleted == nil) and x.message_type_id != 8 }
        @streams = unread_streams.paginate(:per_page => per_page, :page => params[:page] || 1)
      elsif params[:by] == "favourites"
        favourites = @streams & current_user.favourites
        @streams = favourites.paginate(:per_page => per_page, :page => params[:page] || 1)
      elsif params[:by] == "edintity"
        edintity = @streams.select{|x| (x.service_id == nil and x.is_deleted == nil) and x.message_type_id != 8}
        @streams = edintity.paginate(:per_page => per_page, :page => params[:page] || 1)
      end
    else
      service_streams = @streams.select {|x| (x.service_id == params[:service_id].to_i and x.is_deleted == nil) and x.message_type_id != 8 }
      @streams = service_streams.paginate(:per_page => per_page, :page => params[:page] || 1)
    end
    render :update do |page|
      page.replace_html "stream_content", :partial => "streams/index"
      page << "$j('#stream_content').show();"
    end
  end

  def display_streams
    user_tab = current_user.user_tabs.find_by_id(params[:id], :include => [:tab])
    @no_post_panel = true
    #    @stream_header = user_tab.tab.tab_path
    load_instances(false)
    @streams = current_user.send("#{@stream_header}_streams")
    unless @streams.blank?
      @streams = @streams.paginate(:per_page => 10, :page => params[:page] || 1)
    end
    @display_in_tabs = true
    render :index
  end

  def filter_streams
    per_page = 10
    @streams = []
    @filter = true
    @by = params[:by]
    @service_id = params[:service_id]
    unless params[:brand_id].blank?
      brand = Brand.find(params[:brand_id])
      if brand.is_default?
        brand = brand.company
      end
      
      @stream_actions = brand.read_or_create_stream_actions
      if params[:by]
        #TODO: Move all the queries to model
        if params[:by] == "all"
          @streams = brand.streams.displayed_for_brand.paginate(:per_page => per_page, :page => params[:page] || 1)
        elsif params[:by] == "read"
          @streams = brand.streams.read_items.paginate(:per_page => per_page, :page => params[:page] || 1)
        elsif params[:by] == "unread"
          @streams = brand.streams.unread_items.paginate(:per_page => per_page, :page => params[:page] || 1)
        elsif params[:by] == "favourites"
          @streams = brand.favourites.paginate(:per_page => per_page, :page => params[:page] || 1)
        elsif params[:by] == "edintity"
          @streams = brand.streams.edintity_brand_streams.paginate(:per_page => per_page, :page => params[:page] || 1)
        end
      else
        @streams = brand.streams.displayed_for_brand.find(:all, :conditions => "service_id = #{params[:service_id]}").paginate(:per_page => 25, :page => params[:page] || 1)
      end
    
    else
      @stream_actions = current_user.read_or_create_stream_actions
      if params[:by]
        #TODO: Move all the queries to model
        if params[:by] == "all"
          @streams = current_user.streams.displayed.paginate(:per_page => per_page, :page => params[:page] || 1)
        elsif params[:by] == "read"
          @streams = current_user.streams.read_items.paginate(:per_page => per_page, :page => params[:page] || 1)
        elsif params[:by] == "unread"
          @streams = current_user.streams.unread_items.paginate(:per_page => per_page, :page => params[:page] || 1)
        elsif params[:by] == "favourites"
          @streams = current_user.favourites.paginate(:per_page => per_page, :page => params[:page] || 1)
        elsif params[:by] == "edintity"
          @streams = current_user.streams.edintity_streams.paginate(:per_page => per_page, :page => params[:page] || 1)
        end
      else
        @streams = current_user.streams.displayed.find(:all, :conditions => "service_id = #{params[:service_id]}").paginate(:per_page => per_page, :page => params[:page] || 1)
      end
    end
    render :update do |page|
      page.replace_html "stream_content", :partial => "streams/index"
      page << "$j('#stream_content').show();"
    end
  end


  def search_streams
    search_streams = current_user.saved_searches.collect{|x| x.search_for}
    @search_filter = true
    if search_streams.include?(params[:search_for])
      @saved_search = SavedSearch.find_by_search_for(params[:search_for])
    end
    get_search_streams
    @streams = @streams.paginate(:per_page => 10, :page => 1)
    if params[:saved_id]
      @saved_search = current_user.saved_searches.find_by_id(params[:saved_id])
    end
    # Commented below line as we changed the ajax search to direct search
=begin
    render :search_streams do |page|
      #TODO: Move all js call to function and call that function
      page << "$j('#stream_notify').hide();"
      page << "$j('.top_menu').hide();"
      page << "$j('.stream.rounded').hide();"
      page << "$j('.play').hide();"
      page << "$j('#unread_items_count').hide();"
      page << "$j('.no_users').hide();"
      page << "$j('.find_friends').hide();"
      page << "$j('.content_div').hide();"
      page << "$j('.users_list').hide();"
      page << "$j('.posttype').hide();"
      page << "$j('.new_item_bar_div').hide();"
      page << "$j('.headStreamSection').hide();"
      page.replace_html "stream_content", :partial => "streams/index", :locals => {:search => true}
      page.insert_html :top, 'stream_content', :partial => "home/search_result_header", :locals => {:params => params}
      page << "$j('#stream_content').show();"
    end
=end
  end

  def get_search_streams
    #TODO: Move all the queries to model
    if params[:search_type] == "edintity"
      @streams = params[:search_for].strip != "" ? Stream.find(:all, :include => [:sender, :user_service], :order => "stream_created_at DESC", :conditions => ["
                  (streams.text like ? or streams.flickr_photo_title like ? or streams.facebook_feed_description like ? or
                  streams.description like ? or  streams.tumblr_data_one like ? or
                  streams.tumblr_data_two like ? or stream_details.name like ?) and (user_services.privacy_type_id = 1 or user_services.privacy_type_id is null or user_services.privacy_type_id = '' )",
          "%#{params[:search_for]}%", "%#{params[:search_for]}%","%#{params[:search_for]}%","%#{params[:search_for]}%","%#{params[:search_for]}%","%#{params[:search_for]}%","%#{params[:search_for]}%"]) : []
    else
      @streams = params[:search_for].blank? ? [] : current_user.streams.find(:all, :include => [:sender], :order => "stream_created_at DESC", :conditions => ["
                  streams.text like ? or streams.flickr_photo_title like ? or streams.facebook_feed_description like ? or
                  streams.description like ? or  streams.tumblr_data_one like ? or streams.tumblr_data_two like ? or stream_details.name like ?",
          "%#{params[:search_for]}%", "%#{params[:search_for]}%","%#{params[:search_for]}%","%#{params[:search_for]}%","%#{params[:search_for]}%","%#{params[:search_for]}%","%#{params[:search_for]}%"])
    end    
  end

  def save_search
    @saved_search = current_user.saved_searches.create(:search_for => params[:search_for], :search_type => params[:search_type])
    render :update do |page|
      #      page << "$j('#stream_notify').hide();"
      page << "notice('search saved successfully')"
      page << "$j('.searchSideBottom .counter').html(#{current_user.saved_searches.count});"
      page.replace_html "savedSearch", :partial => "home/saved_search_list"
      page << "$j('#sideSearchResult').hide();"
      page.insert_html :top, 'stream_content', :partial => "home/search_result_header", :locals => {:params => params}
      #      page.replace_html "sideSearchResult", :partial => "home/search_result_header", :locals => {:params => params}
    end
  end

  def remove_search
    saved_search = current_user.saved_searches.find_by_id(params[:id])
    saved_search.destroy
    render :update do |page|
      #      page << "$j('#stream_notify').hide();"
      page << "notice('removed your saved search successfully')"
      page << "$j('.searchSideBottom .counter').html(#{current_user.saved_searches.count});"
      page.replace_html "savedSearch", :partial => "home/saved_search_list"
      page << "$j('#sideSearchResult').hide();"
      page.insert_html :top, 'stream_content', :partial => "home/search_result_header", :locals => {:params => params}
      #      page.replace_html "sideSearchResult", :partial => "home/search_result_header", :locals => {:params => params}
    end
  end

  def features
    @features = StaticSiteContent.find_by_title("features")
    if request.xhr?
      render :update do |page|
        if (params[:plan] == 'starter')
          page.replace_html "features_content", :partial => "features_starter"
        elsif (params[:plan] == 'premium')
          page.replace_html "features_content", :partial => "features_premium"
        elsif  (params[:plan] == 'business')
          page.replace_html "features_content", :partial => "features_business"
        elsif  (params[:plan] == 'compare')
          page.replace_html "features_content", :partial => "features_comparison"
        end
      end
    end
  end

  def about
    @about = StaticSiteContent.find_by_title("about")
  end

  def terms_of_use
    @terms_of_use = StaticSiteContent.find_by_title("terms of use")
  end

  def privacy_policy
    @privacy_policy = StaticSiteContent.find_by_title("privacy policy")
  end

  def help
    if current_user
      token = "vNl7s43g9TopEXLMMYxHYIgYJh8pdpcleSBPTZpQQhqpXvvt"#ZENDESK_OPTIONS[:token]
      timestamp = Time.now.to_i
      hash = Digest::MD5.hexdigest("#{current_user.user_name}#{current_user.email}#{token}#{timestamp}")
      link = "http://edintitydemo.zendesk.com/login?timestamp=#{timestamp}&name=#{current_user.user_name}&email=#{current_user.email}&hash=#{hash}"
    else
      link = "http://edintitydemo.zendesk.com/"
    end
    redirect_to link
  end

  def welcome
    @membership = current_user.membership
    case @membership.id
    when 1 then
      redirect_to :action => :welcome_starter
    when 2 then
      redirect_to :action => :welcome_premium
    when 3 then
      redirect_to :action => :welcome_bronze
    when 4 then
      redirect_to :action => :welcome_silver
    when 5 then
      redirect_to :action => :welcome_gold
    when 6 then
      redirect_to :action => :welcome_platinum
    else
      redirect_to root_url
    end
  end

  def tutorial
    @video_url = case params[:name]
    when "what_is_edintity"
      session[:locale] == "arabic" ? "http://www.youtube.com/watch?v=KXfYZKKVDTI&list=PL0B2D2183338BA9F5&index=1&feature=plpp_video" : "http://www.youtube.com/watch?v=HQa4kqTaQC8&list=PL2AA3A8216F5B08D3&index=1&feature=plpp_video"
    when "signing_up_for_an_account"
      session[:locale] == "arabic" ? "http://www.youtube.com/watch?v=ExS9RavzdFk&list=PL0B2D2183338BA9F5&index=2&feature=plpp_video" : "http://www.youtube.com/watch?v=LU52Py5_x4s&feature=bf_next&list=PL2AA3A8216F5B08D3&lf=plpp_video"
    when "explore_edintity"
      session[:locale] == "arabic" ? "http://www.youtube.com/watch?v=obbR2612ypU&feature=BFa&list=PL0B2D2183338BA9F5&lf=plpp_video" : "http://www.youtube.com/watch?v=LO-FUWcX_-o&feature=bf_next&list=PL2AA3A8216F5B08D3&lf=plpp_video"
    end
  end

  def set_periodic_refresh_frequency
    current_user.refresh_period = params[:period].blank? ? nil : params[:period]
    current_user.save
    render :update do |page|
      unless params[:period].blank?
        page.replace_html "periodic_call", :partial => "home/periodic_call", :locals => {:refresh_period => current_user.refresh_period}
      else
        page.replace_html "periodic_call", ""
      end
      page << "$j('#refreshOptions').hide();"
    end
  end

  def activation_reminder
    @header = "#{t :activation_reminder}"
    session[:activation_reminder] = nil
    render :layout => 'redbox'
  end

  private

  def load_instances(home_streams = true)
    @current_user = User.find(current_user.id, :include => [:user_tabs, :streams, :preferences, :brand_user_groups, :user_privacy_setting, :favourite_streams])
    @current_user.update_attributes(:status => "5")
    #    @user_tabs = @current_user.active_tabs
    #    @user_unused_tabs = @current_user.unused_tabs
    #    @stream_actions = @current_user.read_or_create_stream_actions
    if home_streams
      @stream_count = @current_user.streams.not_displayed.count if @no_post_panel.blank?
      @unread_items = @current_user.streams.unread_items.count
      @streams = @current_user.streams.send(request.path.inspect.index("social_inbox") ? "from_services" : "edintity_streams").paginate(:page => 1, :per_page => 10)
    end
    @show_popup = current_user.preferences.find_all_by_preference_id(1).length == 0
    @post_types = current_user.membership_id == 1 ? PostType.find(:all, :conditions => "name <> 'Video'") : PostType.find(:all)
    @tab_name = "home"
    @upload_setting = UploadSetting.first
    @status_service_ids = current_user.get_status_service_ids
    @blog_service_ids = current_user.get_blog_service_ids
    @video_service_ids = current_user.get_video_service_ids
    @photo_service_ids = current_user.get_photo_service_ids
  end

  def get_feeds_from_services
    @messages_hash, errors = UserSession.get_twitter_messages(current_user) if current_user.has_twitter_service
    #TODO: Move all the queries to model
    UserSession.get_flickr_messages(current_user) if current_user.has_flickr_service
    UserSession.get_facebook_messages(current_user) if current_user.has_facebook_service
    UserSession.get_facebook_page_messages(current_user) if current_user.has_facebook_page
    UserSession.get_vimeo_videos(current_user) if current_user.has_vimeo_service
    UserSession.get_youtube_videos(current_user) if current_user.has_youtube_service
    UserSession.get_tumblr_messages(current_user) if current_user.has_tumblr_service
    UserSession.get_delicious_messages(current_user) if current_user.has_delicious_service
    UserSession.get_stumbleupon_messages(current_user) if current_user.has_stumbleupon_service
    return errors
  end


  #TODO Code to be reviewed
  def get_company_feeds_from_services(brand)
    @messages_hash, errors = UserSession.get_twitter_messages(brand) if brand.has_twitter_service
    #TODO: Move all the queries to model
    UserSession.get_flickr_messages(brand) if brand.has_flickr_service
    UserSession.get_facebook_messages(brand) if brand.has_facebook_service
    UserSession.get_vimeo_videos(brand) if brand.has_vimeo_service
    UserSession.get_youtube_videos(brand) if brand.has_youtube_service
    UserSession.get_tumblr_messages(brand) if brand.has_tumblr_service
    UserSession.get_delicious_messages(brand) if brand.has_delicious_service
    UserSession.get_stumbleupon_messages(brand) if brand.has_stumbleupon_service
    return errors
  end  

end
