class Companies::BrandsController < ApplicationController
  before_filter :require_user
  require 'twitter_oauth'
  require 'facebook_oauth'
  include TwitsHelper
  include FacebookHelper
  include FlickrHelper
  include VimeoHelper
  include TumblrHelper
  before_filter :load_instances, :only => [:index, :new, :edit, :show, :services, :privacy]
  before_filter :check_access, :only => [:show, :new, :edit, :create, :update, :update_privacy, :destroy]
  before_filter :active_company,:only => [:update, :create, :create_service, :destroy]
  def index
  end

  def new
    @brand = Brand.new
    #TODO: Brand should be find with relation to user and company model and not directly Brand.find
    @parent_brand = params[:brand_id].blank? ? current_user.company.brands.default_active_brand : Brand.find(params[:brand_id])
    render :layout => false if request.xhr?
  end

  def add
    @brand = Brand.new
    @company = current_user.company
    @parent_brand = params[:brand_id].blank? ? current_user.company.brands.default_active_brand : Brand.find(params[:brand_id])
    render :layout => "redbox"
  end

  def edit
    @brand = Brand.find(params[:id])
    render :layout => false if request.xhr?
  end

  def get_company_brands_data
    @company_brands_data = current_user.company.get_company_brands_data(@dates[0], @dates[1])
  end

  def get_brand_locations_data
    @company_brands = current_user.company.brands.blank? ? [] : current_user.company.brands.collect{|brand| [brand.id, brand.name]}
    @brand_locations_data = @brand ? @brand.get_locations_data(@dates[0], @dates[1]) : [['No data'], [[[DateTime.parse(@dates[0]).to_i*1000, 0], [DateTime.parse(@dates[1].gsub('23:59:59','00:00:00')).to_i*1000, 0]]]]
  end

  def set_dates
    @start_date = params[:start_date] || (Time.now - 15552000).strftime("%m/%d/%Y")
    @end_date = params[:end_date] || (Time.now).strftime("%m/%d/%Y")
    start_array = @start_date.split("/")
    end_array = @end_date.split("/")
    start_date = "#{start_array[2]}-#{start_array[0]}-#{start_array[1]} 00:00:00"
    end_date = "#{end_array[2]}-#{end_array[0]}-#{end_array[1]} 23:59:59"
    [start_date, end_date]
  end

  def create
    @parent_brand = Brand.find(params[:brand_id])
    if @parent_brand.company.is_allowed_to_create_brand?
      @brand = @parent_brand.subbrands.new(params[:brand])
      @brand.company_id = params[:company_id]
      @brand.active_skin_id = Skin::edintity_default.id
      @brand.is_default = false
      @brand.active = true
      if @brand.save
        if request.xhr?
          render :update do |page|
            if params[:from] == "add"
             page.hide "RB_redbox"
             page.insert_html :bottom, "brand_list_div", :partial => "companies/brand", :locals => { :brand => @brand }
            elsif params[:from] == "new"
             page.hide  "edit_or_add_brand_#{@parent_brand.id}"
             page <<  " jQuery('#add_new_brand').hide(); if(jQuery('#add_new_brand'))"
             page.insert_html :bottom, "brandListingul", :partial => "companies/brands/brand_item", :locals => { :brand => @brand }
            end
          end
        else
          flash[:notice] = "Brand created successfully"
          unless params[:scope]
            redirect_to services_company_brand_path(@brand.company_id,@brand.id)
          else
            redirect_to "/brands/#{@brand.company.id}/#{@brand.id}"
#            redirect_to company_brand_path(@brand.company, @brand.id)
          end
        end
      else
        render :update do |page|
          page << "notice('Brand not created. Please enter the details properly')"
        end
      end
    else
      render :update do |page|
        page << "notice('You have reached brand creation limit, please upgrade your company account to create more brands')"
      end
    end
  end

  def update
    @brand = Brand.find(params[:id])
    @brand.update_attributes(params[:brand])
    @brand.company.update_attributes({:name => params[:brand][:name], :url => params[:brand][:brand_url], :description => params[:brand][:description]}) if @brand.is_default?
    if request.xhr?
      render :update do |page|
        page.replace_html "brand_#{@brand.id}", :partial => "companies/brands/brand_item", :locals => { :brand => @brand }
      end
    else
      redirect_to company_brand_path(@brand.company, @brand.id)
    end
    
  end

  def show
    @sub_brands = @brand.subbrands
  end

  def services
    @brand = Brand.find(params[:id] || params[:brand_id])
    @service_categories = ServiceCategory.all
    init_services
    display_service
    @sub_brands = @brand.subbrands
  end

  def init_services
    @service_categories = ServiceCategory.all
    @user_services = current_user.user_services
    @social_networking_services = Service.social_networking_services
    @video_publishing_services = Service.video_publishing_services
    @bookmarking_services = Service.bookmarking_services
    @blogging_services = Service.blogging_services
    @photo_sharing_services = Service.photo_sharing_services
  end

  def add_services
    @service_configurations = []
    @user_service = BrandService.new
    @privacy_groups = current_user.privacy_groups
    if params[:service_id]
      @service = Service.find_by_id(params[:service_id])
      @service_configurations = ServiceConfiguration.find(:all, :conditions => "id in (#{@service.service_configuration_ids})") unless @service.service_configuration_ids.blank?
      @header = "Configuring #{@service.name}"
    end
    render :layout => "redbox"
  end

  def create_service
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
        @user_service = BrandService.find(params[:user_service_id])
        @service = Service.find(params[:service_id])
        get_service
      else
        @service = Service.find(params[:service_id])
        @user_service = BrandService.new(:service => @service, :user => current_user, :privacy_type_id => params["user_service"]["privacy_type_id"], :service_configuration_ids => params[:service_configuration_ids].blank? ? "" : params[:service_configuration_ids].join(',') )
        get_service
      end
    end
  end

  def get_service
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
      @user_service.update_attributes(:token => params[:url], :secret => "Tumblr", :profile_name => params[:url], :user_name => params[:url])
      flash[:notice] = "#{t :service_saved}"
      redirect_to services_company_brands_url
    elsif @user_service.service_id == Service::SERVICES_ID[:delicious]
      @user_service.update_attributes(:token => params[:url], :secret => "Delicious", :profile_name => params[:url], :user_name => params[:url])
      flash[:notice] = "#{t :service_saved}"
      redirect_to services_company_brands_url
    elsif @user_service.service_id == Service::SERVICES_ID[:stumbleupon]
      @user_service.update_attributes(:token => params[:url], :secret => "StumbleUpon", :profile_name => params[:url], :user_name => params[:url])
      flash[:notice] = "#{t :service_saved}"
      redirect_to services_company_brands_url
    else
      flash[:notice] = "#{t :service_invalid}"
      redirect_to services_company_brands_url
    end

  end

  def privacy
    @brand = Brand.find(params[:brand_id])
    @sub_brands = @brand.subbrands
    @brand_privacy_types = PrivacyType.find(:all).map{|s| [s.name,s.id]}
    @brand_privacy_setting = @brand.brand_privacy
  end

  def update_privacy
    unless params[:brand_id].blank?
      @brand = Brand.find(params[:brand_id])
      @company = @brand.company
    else
      @company = Company.find(params[:company_id], :include => [:brands])
      @brand = @company.default_brand
    end

    @company.brands.each do |brand|
      brand.brand_privacy.update_attributes(params["brand_privacy_#{brand.id}"]) unless params["brand_privacy_#{brand.id}"].blank?
    end

    render :update do |page|
      page << "notice('#{t :brand_updated}')"
    end
  end

  def destroy
    @brand = Brand.find(params[:id])
    company = @brand.company
    @brand.delete_brands
    if request.xhr?
      @brands = company.brands
      render :update do |page|
        page << "Effect.Fade('brand_#{@brand.id}')"
        page.replace_html "addBrandLink", "#{link_to_remote_redbox("+", {:url => add_company_brand_path(@brand.company, :brand_id => @brand.parent.id )})}"
#        page.replace "pick_a_brand", select_tag("pick_a_brand", options_from_collection_for_select(@brand.parent.subbrands + [@brand],:id,:name), :class => "rounded") if @brand.parent.subbrands
        page << "notice('#{t :brand_deleted}')"
      end
    else
      flash[:notice] ="#{t :brand_deleted}"
      redirect_to edit_company_path(@brand.company)
    end
  end

  def profile
    @brand = Brand.find_by_url(params[:id]) || Brand.find_by_id(params[:id])
    if @brand
      @user = current_user
      @streams = @brand.streams.displayed_for_brand.paginate(:page => 1, :per_page => 25)
      @stream_actions = @brand.read_or_create_stream_actions
      @background_attributres = StyleAttribute.background
      @font_attributres = StyleAttribute.font
      @panel_types = PanelType.all
      @skin_styles = {}
      @skin = @brand.active_skin
      @default_skin = Skin.edintity_default
      @my_skins = @brand.skins
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
    else
      #      flash[:notice] = "No brand exists"
      redirect_to root_url
    end
  end

  #TODO: Incomplete Code
  def followers
    @company = Company.find_by_id(params[:id])
    if @company
      #      @followers = @user.get_followers - @user.friends
      #      render :update do |page|
      #        page << "$j('.text_followers').addClass('selected_tab');$j('.text_following,.text_friends').removeClass('selected_tab')"
      #        page.replace_html "stream_content", :partial => "followers"
      #      end
    end
  end

  def apply_skin
    @brand = Brand.find(params[:id])
    @brand.update_attribute(:active_skin_id, params[:skin_id])
    redirect_to :action => :profile, :id => @brand.name, :apply_skin => true
  end



  private

  def load_instances(home_streams = true)
    @user_tabs = current_user.active_tabs
    @user_unused_tabs = current_user.unused_tabs
    @brand = Brand.find(params[:id] || params[:brand_id], :include => [:company]) if params[:id] || params[:brand_id]
    @company = @brand.company
    #    @company_membership = current_user.company.membership
    if home_streams
      #@stream_count = brand.streams.not_displayed.count if @no_post_panel.blank?
      # @unread_items = brand.streams.unread_items.count
      @streams = @brand.streams.displayed_for_brand.paginate(:page => 1, :per_page => 25) if @brand
    end
    @show_popup = current_user.preferences.find_all_by_preference_id(1).length == 0
    @post_types = PostType.find(:all)
    @tab_name = "home"
    @dates = set_dates
    get_brand_locations_data if current_user.company
  end

  def display_service
    #  @brand=Brand.find_by_id(params[:id])
    @my_services = @brand.active_services
    @pending_services = @brand.pending_services

  end

  def check_access
    @company = Company.find(params[:company_id] || params[:id] )
    @brand = Brand.find(params[:id] || params[:brand_id], :include => [:company]) if params[:id] || params[:brand_id] 
    if @company.is_brand_admin?(current_user) || @brand.is_brand_manager?(current_user) || @brand.is_content_manager?(current_user)
      true
    else
      if request.xhr?
        render :update do |page|
          page << "notice('You are not allowed to access this page')"
        end
      else
        flash[:notice] = "You are not allowed to access this page"
        redirect_to root_url
      end
    end
  end

end
