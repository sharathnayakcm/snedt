class CompaniesController < ApplicationController
  
  layout "application"
  before_filter :require_user, :except => [:company_name_validation, :payment_success]
  require 'twitter_oauth'
  include TwitsHelper
  include HomeHelper
  include UserHelper
  before_filter :active_company,:only => [:update, :new, :create, :delete_brands_and_company]
  #  before_filter :current_company,:only => [:edit,:profile]
#  before_filter :check_access, :only => [:show, :edit, :before_destroy, :delete_brands_and_company, :downgrade, :downgrade_membership]
  
  def index
    if(current_user.company && (current_user.check_payment_status? == true || (current_user.check_payment_status? == false && current_user.company.membership.is_trial_period_allowed?)))
      load_instances
      if current_user.check_payment_status? == false
        current_user.company.payments.create({:company_id => @company.id, :status => Payment::STATUS[:success], :vendor => "Free Trial Period", :amount => 0})
        flash[:notice] = "Your brand #{current_user.company.name} for which payment is pending is upgraded to free trail period of 30-days"
      end
    elsif current_user.company && current_user.check_payment_status? == false
      @no_post_panel = true
      redirect_to payment_options_users_path(:membership_id => current_user.company.membership_id, :user_id => current_user.id, :from_company => true)
    else
      render :partial => "shared/company/business_plan", :layout => "application"
    end
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

  def new
    unless !current_user.company.blank?
      @company = Company.new
      session[:membership_id] = params[:membership_id] || session[:membership_id]
      @membership = Membership.active.business.find(session[:membership_id])
      load_instances
    else
      redirect_to company_path(current_user.company.name)
    end
  end

  def show
    @scope = "company"
    load_instances
  end

  def create
    @membership = Membership.active.business.find(session[:membership_id])
    @company = Company.new(params[:company])
    @company.user = current_user
    @company.membership_id = params[:membership_id]
    @company.active = true
    if @company.save
      if params[:payment]
        if @membership.is_trial_period_allowed?
          @company.user.payments.create({:company_id => @company.id, :status => Payment::STATUS[:success], :vendor => "Free Trial Period", :amount => 0})
          flash[:notice] ="#{t :company_created}"
          redirect_to company_path(@company.name)
        else
          @company.user.payments.create({:membership_id => @company.membership_id, :amount => @company.membership.amount})
          redirect_to payment_options_users_path(:membership_id => params[:membership_id], :user_id => current_user.id, :from_company => true)
        end
      else
        flash[:notice] ="#{t :company_created}"
        redirect_to company_path(@company.name)
      end
    else
      flash[:notice] = "#{@company.errors.full_messages.join('. ')}"
      render :action => :new
    end
  end

  def company_name_validation
    if !params[:company_name].blank?
      params[:company_name] = params[:company_name].downcase
      @existing_company = Company.find_by_name(params[:company_name]) || User.find_by_user_name(params[:company_name])
      if @existing_company.nil? && (params[:company_name] != params[:user_name].to_s.downcase)
        render :update do |page|
          page << "$j('#company_name_check').html('#{'<span class="checkIco correctCheckIco"></span>'}')"
          page << "$j('#company_name').removeClass('validate_failure');$j('#company_name').addClass('validate_success');"
        end
      else
        render :update do |page|
          page << "$j('#company_name_check').html('#{'<span class="checkIco errorCheckIco"></span>'}#{'<div class="formError" style="display: block;"><p>Brand Name has already been taken</p></div>'}')"
          page << "$j('#company_name').addClass('validate_failure');"
          page.replace_html "brand_url", "#{t :brand_url_text}http://BrandName.edintity.com"
        end
      end
    else
       render :update do |page|
         page << "$j('#company_name_check').html('#{'<span class="correctCheckIco"></span>'}')"
       end
    end
  end
  
  def edit
    flash.now[:notice] = params[:notice] if params[:notice]
    @sessionid = params[:sessionid]
    init_edit
    @brand_table = Grid::Company::BrandsPresenter.new(@template)
    @brands = @company.brands
    @user = current_user
    @current_cycle_total_streams = @company.streams.company_edintity_streams.find(:all,:conditions=>{:created_at =>@company.cycle_start_date..@company.cycle_start_date+1.month }).count
    @current_cycle_photo_streams = @company.streams.company_edintity_photo_streams.find(:all,:conditions=>{:created_at =>@company.cycle_start_date..@company.cycle_start_date+1.month }).count
    @current_cycle_status_streams = @company.streams.company_edintity_status_streams.find(:all,:conditions=>{:created_at =>@company.cycle_start_date..@company.cycle_start_date+1.month }).count
    @current_cycle_blog_streams = @company.streams.company_edintity_blog_streams.find(:all,:conditions=>{:created_at =>@company.cycle_start_date..@company.cycle_start_date+1.month }).count
    @current_cycle_link_streams = @company.streams.company_edintity_link_streams.find(:all,:conditions=>{:created_at =>@company.cycle_start_date..@company.cycle_start_date+1.month }).count
    @current_cycle_video_streams = @company.streams.company_edintity_video_streams.find(:all,:conditions=>{:created_at =>@company.cycle_start_date..@company.cycle_start_date+1.month }).count
    load_payments
  end

  def load_payments
    @payments_table = Grid::PaymentsPresenter.new(@template)
    @payments = @company.payments.all(:order => @payments_table.order)
    @payments = @payments.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @payments_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @payments.size)
  end

  def update
    @company = Company.find(params[:id])
    if @company.update_attributes(params[:company])
      render :update do |page|
        page << "$j('#create_account_btn').show();$j('#account_spinner').hide();"
        page << "notice('#{t :profile_updated}')"
      end
    else
      render :update do |page|
        page << "$j('#create_account_btn').show();$j('#account_spinner').hide();"
        page << "notice('#{t :profile_not_updated}')"
      end
    end
  end

  def before_destroy
    @current_user = current_user
    @header = "#{t :delete_account_header}"
    render :layout => 'redbox'
  end

  def delete_brands_and_company
    @company = Company.find(params[:id])
    @company.destroy
#    current_user.update_attribute(:membership_id, 1)
    flash[:notice] ="#{t :company_deleted}"
    redirect_to "/"
  end

  def profile
    @user = current_user
    load_instances
    # @stream_actions = @user.read_or_create_stream_actions
    @background_attributres = StyleAttribute.background
    @font_attributres = StyleAttribute.font
    @panel_types = PanelType.all
    @skin_styles = {}
    @skin = @user.active_skin
    @default_skin = Skin.edintity_default
    @my_skins = @user.skins
    @applying_skin = params[:apply_skin] ? true : false
    @skin = Skin.edintity_default if @skin.blank?
  end

  #TODO : incomplete code
  def followers
    @brand = Brand.find(params[:id])
    if @brand
      @followers = @brand.get_followers - @brand.friends
      render :update do |page|
        page << "$j('.text_followers').addClass('selected_tab');$j('.text_following,.text_friends').removeClass('selected_tab')"
        page.replace_html "stream_content", :partial => "followers"
      end
    end
  end

  def down_or_upgrade
    @membership = Membership.find(params[:membership_id])
    @company = Company.find(params[:id])
    @membership_scope = params[:membership_scope]
    @brand_user_groups = @company.brand_user_groups
    @brand = @company.default_brand(:include => [{:company => [:membership]}, :subbrands, :streams]) unless @company.blank?
    @header = "#{@membership_scope} to #{@membership.name}"
    render :layout => 'redbox'
  end

  def down_or_upgrade_membership
    @membership = Membership.find(params[:membership_id])
    @company = Company.find(params[:id])
    @user = current_user
    if @membership.amount.to_i > 0
      session[:membership_id] = params[:membership_id]
      session[:company_id] = @company.id
      fetch_decrypted(@membership, @company.id, "company")
      @header = "Upgrade to #{t(@membership.name)}"
      render :update do |page|
        page.replace_html "membership_down_upgrade", :partial => "down_or_upgrade_membership"
      end
    else
      @company.update_attribute(:membership_id, @membership.id)
      render :update do |page|
        page.replace_html "user_subscription_edit", :partial => "shared/company/company_subscription_tab"
        page << "notice('Your account downgraded successfully')"
        page << "RedBox.close()"
      end
    end
  end

  def payment_success
    if params[:vendor] == "paypal_credit_cards"
      ids = params["CUSTID"].split("-")
      company_id = ids[0]
      membership_id = ids[1]
      signup = ids[2] == "true" ? true : false
      activation = ids[3] == "true" ? true : false
      locale = ids[4]
    elsif params[:vendor] == "cashu"
      ids = params["txt1"].split("-")
      company_id = ids[1]
      membership_id = ids[2]
      signup = ids[3] == "true" ? true : false
      activation = ids[4] == "true" ? true : false
      locale = ids[5]
    else
      company_id = params[:company_id] || session[:company_id]
      membership_id = params[:membership_id] || session[:membership_id]
      signup = session[:signup]
      activation = session[:activation]
      locale = session[:locale] || "en"
    end
    membership = Membership.find_by_id(membership_id)
    @company = Company.find_by_id(company_id)
    from_membership_id = @company.membership_id
    if @company
#      payment = @company.user.payments.find(:last)
#      payment.update_attributes(:status => Payment::STATUS[:success], :vendor => params[:vendor])
      @company.user.payments.create({:membership_id => membership_id, :company_id => @company.id, :status => Payment::STATUS[:success], :vendor => params[:vendor], :amount => membership.amount})
      @company.update_attributes({:membership_id => membership_id, :next_payment_date => @company.next_payment_date.blank? ? (Time.now + 2592000) : (@company.next_payment_date + 2592000), :cycle_start_date => Time.now, :uploaded_size => 0})
    end
    UserUpgrade.create({:user_id => @company.user.id, :company_id => @company.id, :from_membership_id => from_membership_id, :to_membership_id => @company.membership_id, :from_to => "#{from_membership_id}-#{@company.membership_id}"})
    flash[:notice] = "Your account has been upgraded "
    payment = @company.user.payments.find(:last, :order => "id DESC")
    Notification.deliver_notification("Upgrade membership",@company.user, { "params" => {:next_payment_date => @company.next_payment_date.strftime("%Y-%m-%d"), :now => Time.now.strftime("%Y-%m-%d"), :payment_id => payment.id, :amount => payment.amount, :user_name => @company.user.user_name}}, :locale => session[:locale] == "arabic")
    @company.user.update_attributes({:active => 1})
    UserSession.create(@company.user, false) # Log user in manually
    if params[:vendor] == "cashu"
      redirect_to :action => :back_from_cashu, :to_url => url_for(edit_company_path(@company, :notice => flash[:notice], :sessionid => params[:session_id], :locale => locale, :only_path => false))#"http://edintity.com/users/#{@user.id}/edit?notice=#{flash[:notice]}&sessionid=#{params[:session_id]}&locale=#{locale}"
    else
      redirect_to edit_company_path(@company.id, :locale => locale)
    end
  end


  def back_from_cashu
    @to_url = params[:to_url]
    unless params[:failed]
      @message = "Transaction Successful"
    else
      @message = "Transaction Failed"
    end
  end

  def payment_failure
    if params[:vendor] == "paypal_credit_cards"
      ids = params["CUSTID"].split("-")
      company_id = ids[0]
      membership_id = ids[1]
      signup = ids[2] == "true" ? true : false
      activation = ids[3] == "true" ? true : false
      locale = ids[4]
    elsif params[:vendor] == "cashu"
      ids = params["txt1"].split("-")
      company_id = ids[1]
      membership_id = ids[2]
      signup = ids[3] == "true" ? true : false
      activation = ids[4] == "true" ? true : false
      locale = ids[5]
    else
      company_id = params[:company_id] || session[:company_id]
      membership_id = params[:membership_id] || session[:membership_id]
      signup = session[:signup]
      activation = session[:activation]
      locale = session[:locale] || "en"
    end
    membership = Membership.find_by_id(membership_id)
    @company = Company.find_by_id(company_id)
    @company.payments.create({:membership_id => membership_id, :company_id => @company.id, :status => Payment::STATUS[:failure], :vendor => params[:vendor], :amount => membership.amount}) if @company

    flash[:notice] = "Upgradation failed. Please try again"
    if params[:vendor] == "cashu"
      redirect_to :action => :back_from_cashu, :failed => true, :to_url => url_for(edit_company_path(@company, :notice => flash[:notice], :locale => locale, :only_path => false))#"http://edintity.com/users/#{@user.id}/edit?notice=#{flash[:notice]}&locale=#{locale}"
    else
      redirect_to :action => :edit, :locale => locale
    end
  end


  def downgrade
    @downgrade = true
    @membership = Membership.find(params[:membership_id])
    @company = Company.find(params[:id])
    @brand_user_groups = @company.brand_user_groups
    @brand = @company.default_brand(:include => [{:company => [:membership]}, :subbrands, :streams]) unless @company.blank?
    render :layout => 'redbox'
  end

  def downgrade_membership
    @membership = Membership.find(params[:membership_id])
    @company = Company.find(params[:id])
    @company.update_attribute(:membership_id, @membership.id)
    render :update do |page|
      page.replace_html "user_subscription_edit", :partial => "shared/company/company_subscription_tab"
      page << "notice('Your account downgraded successfully')"
      page << "RedBox.close()"
    end
  end

  def search_brand
    @brands = current_user.company.brands.find(:all, :conditions => ['name LIKE ?',"#{params[:searchword]}%"]) unless params[:searchword].blank?
    @brands = @brands.paginate({ :page => params[:page], :per_page => 10}) unless @brands.blank?
    if(request.xhr? && params[:ajax_search] == 'true')
      render :update do |page|
        page.replace_html "body_content_mid", :partial => "ajax_search_results"
      end
    elsif(request.xhr?)
      render :layout =>false
    else
      @ajax = false
    end
  end

  private

  def load_instances
    @tab_name = "dashboard"
    @user_tabs = current_user.active_tabs
    @user_unused_tabs = current_user.unused_tabs
    if params[:scope] == "affiliation"
      @company = Company.find_by_name(params[:id])
      @brand = @company.default_brand(:include => [{:company => [:membership]}, :subbrands, :streams])
    else
      @brand = current_user.company.default_brand(:include => [{:company => [:membership]}, :subbrands, :streams]) unless current_user.company.blank?
      @company = @brand.company unless @brand.blank?
    end
    if @brand
      @stream_count = @brand.streams.not_displayed_for_brands.count if @no_post_panel.blank?
      @streams_count = @brand.streams.displayed_for_brand
      @unread_items = @brand.streams.unread_items.count
      @streams = @brand.streams.displayed_for_brand.paginate(:page => 1, :per_page => 25)
      @company_membership = current_user.company.membership unless params[:scope] == "affiliation"
    end
    @show_popup = current_user.preferences.find_all_by_preference_id(1).length == 0
    @post_types = PostType.find(:all)
    @tab_name = "home"
    @dates = set_dates
    get_brand_locations_data if current_user.company
    @upload_setting = UploadSetting.first
  end

  def init_edit
    @company = Company.find(params[:id], :include => [:brands, :membership, :brand_user_groups])
    @brand = @company.default_brand
    @memberships = Membership.business - [@company.membership]
    usage = (@company.uploaded_size.to_i)/(@company.membership.upload_limit)/(@company.membership.upload_limit.to_f)
    @current_usage = (usage * 1000).round.to_f / 1000
    @notifications = Notification.find(:all, :conditions => {:is_displayable => true})
    @brand_user_groups = @company.brand_user_groups
    @service_categories = ServiceCategory.all
    @user_services = current_user.user_services
    @social_networking_services = Service.social_networking_services
    @video_publishing_services = Service.video_publishing_services
    @bookmarking_services = Service.bookmarking_services
    @blogging_services = Service.blogging_services
    @photo_sharing_services = Service.photo_sharing_services
    @privacy_groups = current_user.privacy_groups
    @privacy_setting = current_user.read_or_create_privacy_setting
    @blocked_users = current_user.blocked_users
    @payments = @company.payments
  end

  def check_access
    if params[:scope] == "affiliation"
      @company = Company.find_by_name(params[:id])
      @brand = @company.default_brand(:include => [{:company => [:membership]}, :subbrands, :streams])
    else
      @brand = current_user.company.default_brand(:include => [{:company => [:membership]}, :subbrands, :streams]) unless current_user.company.blank?
      @company = @brand.company unless @brand.blank?
    end
    if @company.is_brand_admin?(current_user) || @company.default_brand.is_brand_manager?(current_user) || @company.default_brand.is_content_manager?(current_user)
      true
    else
      flash[:notice] = "You are not allowed to access this page"
      redirect_to root_url
    end
  end
  #till here
end
