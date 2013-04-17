class Companies::ServicesController < ApplicationController
  #  before_filter :check_status, :only => :new
  before_filter :require_user
  before_filter :load_user
  require 'twitter_oauth'
  require 'facebook_oauth'
  include TwitsHelper
  include FacebookHelper
  include FlickrHelper
  include VimeoHelper
  include TumblrHelper
  before_filter :active_company,:only => [:update, :create, :update_service, :delete_user_service]

  def index
    @brand = params[:scope] == "brands" ? Brand.find_by_id(params[:brand_id]):current_user.company.default_brand
    if @brand
      @service_categories = ServiceCategory.all
      @social_networking_services = Service.social_networking_services
      @video_publishing_services = Service.video_publishing_services
      @bookmarking_services = Service.bookmarking_services
      @blogging_services = Service.blogging_services
      @photo_sharing_services = Service.photo_sharing_services
      display_service
    else
      redirect_to home_path
    end
  end

  def new
    if params[:delete_service]
      @brand = Brand.find_by_id(params[:brand_id])
      if params[:service_id]
        @service = Service.find_by_id(params[:service_id])
        @header = "Unsubscribe #{@service.name}"
        @icon_name = @service.name.downcase.capitalize
      end
    else
      @service_configurations = []
      @brand = Brand.find_by_id(params[:brand_id])
      @user_service = BrandService.new
      #@privacy_groups = current_user.privacy_groups
      if params[:service_id]
        @service = Service.find_by_id(params[:service_id])
        @service_configurations = ServiceConfiguration.find(:all, :conditions => "id in (#{@service.service_configuration_ids})") unless @service.service_configuration_ids.blank?
        @header = "Configuring #{@service.name}"
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
    @brand=Brand.find(params[:brand_id])
    session[:class]="Brand"
    session[:newbrand]= params[:newbrand]
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
        @user_service = BrandService.find_by_id(params[:user_service_id])
        @service = Service.find(params[:service_id])
        get_service
      else
        @service = Service.find(params[:service_id])
        #TODO
        
        @user_service = BrandService.new(:service => @service, :brand => @brand,:company_id=>@brand.company_id,:user_id=>current_user.id, :service_configuration_ids => params[:service_configuration_ids].blank? ? "" : params[:service_configuration_ids].join(',') )
        get_service
      end
    end
  end

  def get_service
    @user_service.save_with_validation(false)
    @user = current_user
    if @user_service.service_id == Service::SERVICES_ID[:twitter]
      authenticate_user(true)
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
      redirect_to company_services_path(current_user.company)
    elsif @user_service.service_id == Service::SERVICES_ID[:stumbleupon]
      @user_service.update_attributes(:token => params[:url], :secret => "StumbleUpon", :profile_name => params[:url], :user_name => params[:url])
      flash[:notice] = "#{t :service_saved}"
      redirect_to company_services_path(current_user.company)
    else
      flash[:notice] = "#{t :service_invalid}"
      redirect_to company_services_path(current_user.company)
    end

  end
  def edit
    @user_service = BrandService.find(params[:user_service_id])
  end

  def update_service
    @user_service = BrandService.find_by_id(params[:user_service_id])
    @user_service.update_attributes( :service_configuration_ids => params[:service_configuration_ids].join(','), :privacy_type_id => params["user_service"]["privacy_type_id"])
    if @user_service.service_id == Service::SERVICES_ID[:tumblr] || @user_service.service_id == Service::SERVICES_ID[:delicious] || @user_service.service_id == Service::SERVICES_ID[:stumbleupon]
      @user_service.update_attributes(:token => params[:url], :profile_name => params[:url], :user_name => params[:url])
    end
    flash[:notice] ="#{t :service_updated}"
    redirect_to services_company_brand_path(current_user.company,@user_service.brand_id)
    return
  end

  def display_service
    @my_services = @brand.active_services
    @pending_services = @brand.pending_services
  end

  def delete_user_service
    @user_service = BrandService.find(params[:id])
    delete_all_streams(params[:id])
    @user_service.destroy
    flash[:notice] = "#{t :service_deleted}"
    redirect_to user_services_url
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
end
