class Users::ServicesController < ApplicationController
  #  before_filter :check_status, :only => :new
  before_filter :require_user, :except => :back_from_cashu
  before_filter :load_user
  require 'twitter_oauth'
  require 'facebook_oauth'
  include TwitsHelper
  include FacebookHelper
  include FlickrHelper
  include VimeoHelper
  include TumblrHelper

  def index
    session[:signup] = (params[:signup]== "true" ? true:false)
    user = User.find_by_id(params[:user_id])
    @privacy_setting = current_user.read_or_create_privacy_setting
    #Notifier.deliver_activation_instructions!(user)
    if user.active?
      @user_service = UserService.new
      init_services
      display_service
    else
      redirect_to login_path
    end
  end

  def new
    if params[:delete_service]
      @user_service = UserService.find_by_id(params[:user_service_id])
      if params[:service_id]
        @service = Service.find_by_id(params[:service_id])
        @header = "Unsubscribe #{@service.name}"
        @icon_name = @service.name.downcase.capitalize
      end
    else
      @service_configurations = []
      @user_service = UserService.new
      @privacy_groups = current_user.privacy_groups
      if params[:service_id]
        @service = Service.find_by_id(params[:service_id])
        @service_configurations = ServiceConfiguration.find(:all, :conditions => "id in (#{@service.service_configuration_ids})") unless @service.service_configuration_ids.blank?
        @header = "Configuring #{@service.name}" unless params[:pending_service]
        @icon_name = @service.name.downcase.capitalize
      end
    end
    render :layout => "redbox"
  end

  def add_new
    user = User.find_by_id(params[:user_id])
    user.update_attribute(:status, "5")
    display_service
    if user.active?
      @service = Service.new
    else
      redirect_to login_path
    end
  end

  def create
    session[:class]="User"
    if params[:commit] == "Save"
      update_service
      return
    end
    if params[:service_layout]
      redirect_to user_friends_path(current_user)
    else
      if params[:edit] == "true"
        update_service
      elsif params["pending_service"] == "true"
        @user_service = UserService.find(params[:user_service_id])
        @service = Service.find(params[:service_id])
        get_service
      else
        @service = Service.find(params[:service_id])
        @user_service = UserService.new(:service => @service, :user => current_user)
        get_service
      end
    end
  end

  def get_service
    signup = session[:signup].blank? ? false : true
    @user_service.save_with_validation(false)
    @user = current_user
    if @user_service.service_id == Service::SERVICES_ID[:twitter]
      authenticate_user(false)
      flash[:notice] = "#{t :service_saved_and_authenticated}"
      redirect_to @link
    elsif @user_service.service_id == Service::SERVICES_ID[:flickr]
      authenticate_flickr_user
      session[:user_service_id] = @user_service.id
      flash[:notice] = "#{t :service_saved}"
      redirect_to @link
    elsif @user_service.service_id == Service::SERVICES_ID[:facebook]
      session[:fb_client] = authenticate_fb_user
      flash[:notice] = "#{t :service_saved}"
      redirect_to @link
    elsif @user_service.service_id == Service::SERVICES_ID[:facebook_page]
      session[:fb_client] = authenticate_fb_page_user
      flash[:notice] = "#{t :service_saved}"
      redirect_to @link
    elsif @user_service.service_id == Service::SERVICES_ID[:vimeo]
      base = authenticate_vimeo_user
      session[:user_service_id] = @user_service.id
      redirect_to base.authorize_url
    elsif @user_service.service_id == Service::SERVICES_ID[:youtube]
      link = authenticate_youtube_user
      session[:user_service_id] = @user_service.id
      redirect_to link
    elsif @user_service.service_id == Service::SERVICES_ID[:tumblr]
      consumer = get_tumblr_consumer
      if consumer
        request_token = consumer.get_request_token;
        session[:request_token] = request_token
        session[:user_service_id] = @user_service.id
        session[:url] = params[:url]
        redirect_to request_token.authorize_url
      end
    elsif @user_service.service_id == Service::SERVICES_ID[:delicious]
      @user_service.update_attributes(:token => params[:url], :secret => "Delicious", :profile_name => params[:url], :user_name => params[:url])
      flash[:notice] = "#{t :service_saved}"
      redirect_to user_services_url(:signup => signup)
    elsif @user_service.service_id == Service::SERVICES_ID[:stumbleupon]
      @user_service.update_attributes(:token => params[:url], :secret => "StumbleUpon", :profile_name => params[:url], :user_name => params[:url])
      flash[:notice] = "#{t :service_saved}"
      redirect_to user_services_url(:signup => signup)
    else
      flash[:notice] = "#{t :service_invalid}"
      redirect_to user_services_url(:signup => signup)
    end

  end
  def edit
    @user_service = UserService.find(params[:user_service_id])
  end

  def update_service
    @user_service = UserService.find(params[:user_service_id])
    @user_service.update_attributes( :service_configuration_ids => params[:service_configuration_ids].join(','), :privacy_type_id => params["user_service"]["privacy_type_id"])
    if @user_service.service_id == Service::SERVICES_ID[:tumblr] || @user_service.service_id == Service::SERVICES_ID[:delicious] || @user_service.service_id == Service::SERVICES_ID[:stumbleupon]
      @user_service.update_attributes(:token => params[:url], :profile_name => params[:url], :user_name => params[:url])
    end
    flash[:notice] ="#{t :service_updated}"
    redirect_to user_services_url
    return
  end

  def display_service
    @my_services = current_user.active_services
    @pending_services = current_user.pending_services

  end

  def delete_user_service
    signup = session[:signup].blank? ? false : true
    @user_service = params[:scope].blank? ? UserService.find(params[:id]) : BrandService.find(params[:id])
    delete_all_streams(params[:id])
    @user_service.destroy
    flash[:notice] = "#{t :service_deleted}"
    init_services
    if params[:scope].blank?
      redirect_to user_services_url(:signup => signup)
    else
      redirect_to services_company_brand_path(@user_service.company_id, @user_service.brand_id)
    end
  end

  def delete_all_streams(user_service)
    user_services = current_user.streams.find_all_by_user_service_id(user_service)
    user_services.each do |service|
      service.destroy
    end
  end

  def load_user
    @user = User.find_by_id(params[:user_id])
  end

  def back_from_cashu
    user = User.find_by_id(params[:user_id])
    UserSession.create(user, false)
    flash[:notice] = params[:notice]
    redirect_to :action => :index, :signup => params[:signup], :tab => "services", :locale => params[:locale]
  end

  def configure_fb_page
    if params[:scope]
      @user_service = BrandService.find_by_id(params[:user_service_id])
    else
      @user_service = UserService.find_by_id(params[:user_service_id])
    end
    client = UserSession.fb_client(@user_service.token)
    @pages = []
    @header = "Configure your Facebook Page"
    accounts = client.me.accounts
    accounts['data'].each do |account|
      unless account['category'] == 'Application'
        @pages << account
      end
    end
    @icon_name = @user_service.service.name.downcase.capitalize
    render :layout => "redbox"
  end

  def save_facebook_page
    fb_page_values = params[:fb_page_id].split("-")
    unless params[:scope].blank?
      user_service = BrandService.find_by_id(params[:user_service_id])
      user_service.update_attributes({:fb_page_id => fb_page_values[0], :secret => fb_page_values[1], :fb_page_name => fb_page_values[2]})
      flash[:notice] ="#{t :service_updated}"
      redirect_to company_services_path(user_service.company,:scope=>"brand", :brand_id => user_service.brand_id)
    else
      user_service = UserService.find_by_id(params[:user_service_id])
      user_service.update_attributes({:fb_page_id => fb_page_values[0], :secret => fb_page_values[1], :fb_page_name => fb_page_values[2]})
      flash[:notice] ="#{t :service_updated}"
      redirect_to user_services_url
    end
  end

  def init_services
    @service_categories = ServiceCategory.all
    @user_services = current_user.user_services
    @social_networking_services = Service.social_networking_services
    @video_publishing_services = Service.video_publishing_services
    @bookmarking_services = Service.bookmarking_services
    @blogging_services = Service.blogging_services
    @photo_sharing_services = Service.photo_sharing_services
    @privacy_groups = current_user.privacy_groups
    @stream_actions = current_user.read_or_create_stream_actions
    current_user.create_user_service_stream_actions
  end
  
end
