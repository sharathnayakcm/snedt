class UserSessionsController < ApplicationController
  #TODO: Move all the constants to environment files
  #TODO: Use service keys and secret from database.
  layout "application"
  before_filter :require_no_user, :only => [ :create]
  before_filter :require_user, :only => [:destroy, :sign_in, :zendesk_logini, :facebook_callback]
  require 'twitter_oauth'
  require 'facebook_oauth'
  include TwitsHelper
  include FacebookHelper
  include VimeoHelper
  include TumblrHelper
  APP_ID = "152688064798273"
  APP_SECRET_KEY = "2a0d1f86bb9462039bdc4fc265982ac7"
  def new
    @sub_domain = request.host.split(".").first
    if @sub_domain == 'edintity' || @sub_domain == "www" || RAILS_ENV == "development"
      unless current_user
        @user_session = UserSession.new
        @what_is_it = StaticSiteContent.find_by_title("what is it")
        @how_it_works = StaticSiteContent.find_by_title("how it works")
        @is_it_for_me = StaticSiteContent.find_by_title("is it for me")
        flash.now[:notice] = params[:notice] if params[:notice]
      else
        redirect_to "/home"
      end
    else
      profile_lookup
    end

  end

  def index
    
  end



  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      #      cookies["fastpass"] = FastPass.url(CONSUMER_KEY, CONSUMER_SECRET, current_user.email, current_user.user_name, current_user.id)
      user = User.find_by_email(@user_session.email)
      #      if user.id == 412
      #       redirect_to user_services_path(user, :signup => true, :tab => 'services')
      #      else
      #
      flash[:notice] = "#{t :login_success}"
      session[:locale] = user.prefered_language
      session[:activation_reminder] = !user.active
      redirect_back_or_default(root_url)
      #      end
    else
      @what_is_it = StaticSiteContent.find_by_title("what is it")
      @how_it_works = StaticSiteContent.find_by_title("how it works")
      @is_it_for_me = StaticSiteContent.find_by_title("is it for me")
      flash[:notice] = "#{@user_session.errors.full_messages}"
      redirect_to login_path(:email => params[:user_session][:email])
    end
  end

  def before_destroy
    @current_user = current_user
    @header = "#{t :delete_account_header}"
    render :layout => 'redbox'
  end

  def delete_streams_and_account
    unless pwd_verification(current_user,params[:user][:password])
      flash[:notice] ="#{t :pwd_not_matching}"
      redirect_to :controller => :users, :action => :edit
    else
      delete_current_user_streams(current_user)
      # deleting permanently a user account instead of setting active to false
      # current_user.update_attributes!(:active => "false",:deleted_at => Time.now)
      current_user.destroy
      flash[:notice] ="#{t :account_deleted}"
      current_user_session.destroy
      redirect_to login_path
      return
    end

  end

  def pwd_verification(current_user,pwd)
    user_session = {:email => current_user.email, :password => pwd}
    authorize = UserSession.new(user_session)
    if authorize.save
      return true
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = params[:notice] || "#{t :logout_success}"
    #redirect_to login_path
    #    redirect_to login_path
    redirect_to root_path
  end

  def logout
    @user_session = UserSession.new
  end

  def delete_current_user_streams(current_user)
    current_user.streams.delete_all if current_user.streams
  end

  def callback
    begin
      @T_OAUTH = TwitterOAuth::Client.new(:consumer_key => "zVwziK0AW1w5sTPCZ9v4Q", :consumer_secret => "rMX782DKERokrNEAlW1GmwBFOZUwx9XIHh8PvHb0syM" )
      @oauth_verifier = params[:oauth_verifier]
      access_token = @T_OAUTH.authorize( session["token"], session["secret"], :oauth_verifier => @oauth_verifier)
      if (@result = @T_OAUTH.authorized?)
        unless session[:class] == "User"
          user_service = current_user.brand_services.find(params[:user_service_id])
        else
          user_service = current_user.user_services.find(params[:user_service_id])
        end
        user_service.create_or_update_twitter_account_with_oauth_token(access_token.token, access_token.secret, @T_OAUTH.info["screen_name"], @T_OAUTH.info["name"])
        session["token"] = nil
        session["secret"] = nil
        flash[:notice] = user_service.errors.full_messages.join("<br />") unless user_service.errors.blank?
      else
        flash[:notice] = "#{t :authorization_failed}"
      end
      if session[:class] == "Brand"
        unless session[:newbrand] == "false"
          redirect_to services_company_brand_path(user_service.company_id,user_service.brand_id)
        else
          redirect_to company_services_path(:company_id => user_service.company_id,:scope=>"brands",:brand_id=>user_service.brand_id)
        end
      else
        if  session[:signup] == true
          redirect_to user_services_path(current_user,:signup => true )
        else
          redirect_to user_services_path(current_user,:signup => false )
        end
      end
      return
    rescue
      flash[:notice] = "#{t :authorization_failed}"
      if  session[:signup] == true
        redirect_to user_services_path(current_user,:signup => true )
      else
        redirect_to user_services_path(current_user,:signup => false )
      end
    end
  end

  def flickr_callback
    auth_token = flickr.auth.getToken(:frob => params[:frob])
    unless session[:class] == "User"
      user_service = current_user.brand_services.find(session[:user_service_id])
    else
      user_service = current_user.user_services.find(session[:user_service_id])
    end
    session[:user_service_id] = nil
    user_service.create_or_update_flickr_account_with_oauth_token(auth_token)
    flash[:notice] = user_service.errors.full_messages.join("<br />") unless user_service.errors.blank?
    if session[:class] == "Brand"
      unless session[:newbrand] == "false"
        redirect_to services_company_brand_path(user_service.company_id,user_service.brand_id)
      else
        redirect_to company_services_path(:company_id => user_service.company_id,:scope=>"brands",:brand_id=>user_service.brand_id)
      end
    else
      if  session[:signup] == true
        redirect_to user_services_path(current_user,:signup => true )
      else
        redirect_to user_services_path(current_user,:signup => false )
      end
    end
  end

  def tumblr_callback
    unless session[:class] == "User"
      user_service = current_user.brand_services.find(session[:user_service_id])
    else
      user_service = current_user.user_services.find(session[:user_service_id])
    end
    session[:user_service_id] = nil
    token = session[:request_token]
    @access_token = token.get_access_token({:oauth_verifier => params[:oauth_verifier]})
    user_service.create_or_update_tumblr_account_with_oauth_token(params, session[:url])
    flash[:notice] = user_service.errors.full_messages.join("<br />") unless user_service.errors.blank?
    if session[:class] == "Brand"
      unless session[:newbrand] == "false"
        redirect_to services_company_brand_path(user_service.company_id,user_service.brand_id)
      else
        redirect_to company_services_path(:company_id => user_service.company_id,:scope=>"brands",:brand_id=>user_service.brand_id)
      end
    else
      if  session[:signup] == true
        redirect_to user_services_path(current_user,:signup => true )
      else
        redirect_to user_services_path(current_user,:signup => false )
      end
    end
  end

  def facebook_callback
    unless session[:class] == "User"
      @user_service = BrandService.find(params[:user_service_id])
    else
      @user_service = UserService.find(params[:user_service_id])
    end
    page = @user_service.service_id == Service::SERVICES_ID[:facebook_page] ? true : false
    client = fb_client	
    access_token = client.authorize(:code => params[:code])
    session[:fb_client] = nil
    unless session[:class] == "User"
      user = Brand.find(@user_service.brand_id)
      user_service = user.brand_services.find(params[:user_service_id])
    else
      user = User.find(@user_service.user_id)
      user_service = user.user_services.find(params[:user_service_id])
    end
    user_service.create_or_update_facebook_account_with_oauth_token(access_token, client)
    flash[:notice] = user_service.errors.full_messages.join("<br />") unless user_service.errors.blank?
    if session[:class] == "Brand"
      unless session[:newbrand] == "false"
        redirect_to services_company_brand_path(user_service.company_id,user_service.brand_id)
      else
        redirect_to company_services_path(:company_id => user_service.company_id,:scope=>"brands",:brand_id=>user_service.brand_id)
      end
    else
      if  session[:signup] == true
        redirect_to user_services_path(current_user,:signup => true )
      else
        redirect_to user_services_path(current_user,:signup => false )
      end
    end
  end

  def vimeo_callback
    base = Vimeo::Advanced::Base.new(VIMEO_CONSUMER_KEY, VIMEO_CONSUMER_SECRET)
    access_token = base.get_access_token(params[:oauth_token], session[:oauth_secret], params[:oauth_verifier])
    session[:access_token] = access_token
    unless session[:class] == "User"
      user_service = current_user.brand_services.find(session[:user_service_id])
    else
      user_service = current_user.user_services.find(session[:user_service_id])
    end
    session[:user_service_id] = nil
    test = Vimeo::Advanced::Test.new(VIMEO_CONSUMER_KEY, VIMEO_CONSUMER_SECRET, :token => access_token.token, :secret => access_token.secret)
    test_login = test.login
    user_name = test_login["user"]["username"]
    person = Vimeo::Advanced::Person.new(VIMEO_CONSUMER_KEY, VIMEO_CONSUMER_SECRET, :token => access_token.token, :secret => access_token.secret)
    info = person.get_info(user_name)
    profile_name = info["person"]["display_name"]
    user_service.create_or_update_vimeo_account_with_oauth_token(access_token, user_name, profile_name)
    flash[:notice] = "#{t :service_saved}"
    if session[:class] == "Brand"
      unless session[:newbrand] == "false"
        redirect_to services_company_brand_path(user_service.company_id,user_service.brand_id)
      else
        redirect_to company_services_path(:company_id => user_service.company_id,:scope=>"brands",:brand_id=>user_service.brand_id)
      end
    else
      if  session[:signup] == true
        redirect_to user_services_path(current_user,:signup => true )
      else
        redirect_to user_services_path(current_user,:signup => false )
      end
    end
  end

  def youtube_callback
    client = GData::Client::YouTube.new
    client.authsub_token = params[:token]
    access_token = client.auth_handler.upgrade()
    client.authsub_token = access_token if access_token
    user_info = client.get('http://gdata.youtube.com/feeds/api/users/default').body
    new_hash = Hash.from_xml(user_info)
    unless session[:class] == "User"
      user_service = current_user.brand_services.find(session[:user_service_id])
    else
      user_service = current_user.user_services.find(session[:user_service_id])
    end
    user_service.create_or_update_youtube_account_with_oauth_token(access_token, new_hash["entry"]["username"])
    flash[:notice] = "#{t :service_saved}"
    if session[:class] == "Brand"
      unless session[:newbrand] == "false"
        redirect_to services_company_brand_path(user_service.company_id,user_service.brand_id)
      else
        redirect_to company_services_path(:company_id => user_service.company_id,:scope=>"brands",:brand_id=>user_service.brand_id)
      end
    else
      if  session[:signup] == true
        redirect_to user_services_path(current_user,:signup => true )
      else
        redirect_to user_services_path(current_user,:signup => false )
      end
    end
   
  end

  def zendesk_login
    if current_user
      token = "bThlI5armvBA6RBkizxyOmZbnP6Leb8217lZG0wUFUrFKwIV"
      params[:timestamp] = Time.now.to_i
      hash = Digest::MD5.hexdigest("#{current_user.user_name}#{current_user.email}#{token}#{params[:timestamp]}")
      link = "http://edintity.zendesk.com/login?timestamp=#{params[:timestamp]}&name=#{current_user.user_name}&email=#{current_user.email}&hash=#{hash}"
      redirect_to link
    else
      redirect_to "http://edintity.zendesk.com/"
    end
  end

  def zendesk_logout
    redirect_to "http://edintity.zendesk.com/"
  end

  def plans_and_pricing
  end

  #  private
  def profile_lookup
    per_page = 10
    @user = User.find_by_user_name_and_active(@sub_domain, 1)
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
        render :action => "index"
        return
      else
        flash[:notice] = "#{t(:user_profile_blocked)}"
        redirect_to root_url
      end

    end
  end

end
