class UsersController < ApplicationController
  require 'rest_client'
  layout "application", :except => :back_from_cashu
  include ActiveMerchant::Billing
  include UserHelper
  ActiveMerchant::Billing::Base.gateway_mode = :test
  ActiveMerchant::Billing::Base.integration_mode = :test
  ActiveMerchant::Billing::PaypalGateway.pem_file = File.read(File.dirname(__FILE__) + '/../paypal/paypal_cert.pem')
  require 'crypto42'
  before_filter :require_user, :only => [:new, :create, :payment_options]
  before_filter :require_user, :only => [:show, :edit, :update]
  skip_before_filter :verify_authenticity_token, :only => :upload
  Time.zone = "Chennai"

  def new
    @user = User.new
    session[:membership_id] = params[:membership_id] || session[:membership_id]
    @membership = Membership.active.find_by_id(session[:membership_id])
  end

  def search_topic
    @topics = Topic.find(:all,:conditions=>['title LIKE ?',"#{params[:searchword]}%"], :order => 'title', :limit => 5) unless params[:searchword].blank?
    render :update do |page|
      page.replace_html "searchtopicDropdown", :partial => "users/searched_topic"
    end
  end

  def search_stream_topic
    @topics = Topic.find(:all,:conditions=>['title LIKE ?',"#{params[:searchword]}%"], :order => 'title', :limit => 5) unless params[:searchword].blank?
    @streamid = params[:stream]
    @stream = Stream.find_by_id(@streamid)
    render :update do |page|
      page.replace_html "streamtopicDropdown_#{@streamid}", :partial => "users/searched_stream_topic"
    end
  end
  
  def create
    @user = User.new(params[:user])
    @user.status = "1"
    @user.user_name = @user.user_name.downcase
    @user.privacy_type_id = 1
    @user.prefered_language = session[:locale] == 'arabic' ? 'arabic' : 'en'
    valid_company = true
    unless params[:company].blank?
      @company = Company.new(params[:company])
      @company.membership_id = params[:membership_id]
      @user.membership_id = 1
      valid_company = @company.valid?
    else
      @user.membership_id = params[:membership_id]
    end
    # Saving without session maintenance to skip
    # auto-login which can't happen here because
    # the User has not yet been activated
    if valid_company && @user.valid?
      @user.save
      if params[:topic_name_ids].present?
        params[:topic_name_ids].each do |i|
          @topic = Topic.find_by_id(i)
          @user.topics<<(@topic)
        end
      end
      @user.update_timezone(request)
      @user.create_privacy_settings(User::PRIVACY_TYPES[:every_one])
      if !params[:company].blank? && !@company.blank?
        @company.user_id = @user.id
        @company.save
        @invited = CompanyInvitation.find_by_invitee_email_address(@user.email)
        if @invited && params[:invited]&& @invited.is_assigned == false
          @invited.update_attributes(:is_assigned => true)
          BrandUserGroup.create(:company_id => @invited.company_id, :user_id => @user.id, :access_type => @invited.access_type, :status => true)
        end
      end
      if @user.save_without_session_maintenance
        #        @user.create_privacy_settings(params[:user_privacy_setting][:full_name])
        if @user.membership.amount.to_i > 0 || (!@company.blank? && @company.membership.amount.to_i > 0)
          membership = @company.blank? ?  @user.membership : @company.membership
          if membership.is_trial_period_allowed?
            unless @company.blank?
              @company.user.payments.create({:membership_id => membership.id, :company_id => @company.id, :status => Payment::STATUS[:success], :vendor => "Free Trial Period", :amount => 0})
            else
              @user.payments.create({:membership_id => membership.id, :status => Payment::STATUS[:success], :vendor => "Free Trial Period", :amount => 0})
            end
            Notification.deliver_notification("Activation", @user, { "params" => {"account_activation_url" => activate_url(@user.perishable_token, :locale => session[:locale])}}, :locale => session[:locale] == "arabic")
            Notification.deliver_notification("User Creation", "", { "params" => {:user_name => @user.user_name}}, :locale => session[:locale] == "arabic")
            #            flash[:notice] = "#{t :account_created}"
            UserSession.create(@user, false)
            redirect_to user_services_path(@user, :signup => true, :tab => 'services')
          else
            @user.payments.create({:status => Payment::STATUS[:pending]})
            redirect_to :action => :payment_options, :membership_id => params[:membership_id], :user_id => @user.id, :from_company => !params[:company].blank?
          end
        else
          @user.update_attributes({:membership_id => 1, :free_user_since => Time.now, :cycle_start_date => Time.now, :uploaded_size => 0})
          if params[:invited].blank?
            Notification.deliver_notification("Activation", @user, { "params" => {"account_activation_url" => activate_url(@user.perishable_token, :locale => session[:locale])}}, :locale => session[:locale] == "arabic")
            Notification.deliver_notification("User Creation", "", { "params" => {:user_name => @user.user_name}}, :locale => session[:locale] == "arabic")
            #            flash[:notice] = "#{t :account_created}"
            UserSession.create(@user, false)
            redirect_to user_services_path(@user, :signup => true, :tab => 'services')
          else
            UserSession.create(@user, false)
            redirect_to company_path(@company)
          end
        end
      else
        @membership = Membership.active.find_by_id(params[:membership_id])
      end
    else
      @membership = Membership.active.find_by_id(session[:membership_id])
      render :action => :new, :membership_id => params[:membership_id] || session[:membership_id]
    end
  end

  def payment_options
    if params[:locale]
      @membership = Membership.active.find_by_id(session[:membership_id])
      @user = User.find_by_id(session[:user_id])
    else
      @membership = Membership.active.find_by_id(params[:membership_id])
      @user = User.find_by_id(params[:user_id])
      session[:membership_id] = params[:membership_id]
      session[:user_id] = params[:user_id]
    end
    session[:signup] = @signup = true
    @company = @user.company
    fetch_decrypted(@membership, params[:user_id])
  end

  def free_account
    @user = User.find_by_id(session[:user_id])
    if @user
      @user.update_attributes({:membership_id => 1, :free_user_since => Time.now})
      flash[:notice] = "Your account has been downgraded to free"
      Notification.deliver_notification("Activation", @user, { "params" => {"account_activation_url" => activate_url(@user.perishable_token, :locale => session[:locale])}}, :locale => session[:locale] == "arabic")
      Notification.deliver_notification("User Creation", "", { "params" => {:user_name => @user.user_name}}, :locale => session[:locale] == "arabic")
      #      flash[:notice] = "#{t :account_created}"
      redirect_to login_path
    else
      redirect_to login_path
    end
  end

  def payment_success
    do_proceed = true
    if params[:vendor] == "paypal_credit_cards"
      ids = params["CUSTID"].split("-")
      if ids.last == "company"
        do_proceed = false
        redirect_to payment_success_companies_path("CUSTID" => params["CUSTID"], :vendor => "paypal_credit_cards")
        return
      else
        user_id = ids[0]
        membership_id = ids[1]
        signup = ids[2] == "true" ? true : false
        activation = ids[3] == "true" ? true : false
        locale = ids[4]
      end
    elsif params[:vendor] == "cashu"
      ids = params["txt1"].split("-")
      if ids.last == "company"
        do_proceed = false
        redirect_to payment_success_companies_path("txt1" => params["txt1"], :vendor => "cashu")
        return
      else
        user_id = ids[1]
        membership_id = ids[2]
        signup = ids[3] == "true" ? true : false
        activation = ids[4] == "true" ? true : false
        locale = ids[5]
      end
    else
      params[:vendor] = "paypal"
      user_id = params[:user_id] || session[:user_id]
      membership_id = params[:membership_id] || session[:membership_id]
      signup = session[:signup]
      activation = session[:activation]
      locale = session[:locale] || "en"
      if params[:from] == "company"
        redirect_to payment_success_companies_path
        return
      end
    end
    if do_proceed
      membership = Membership.find_by_id(membership_id)
      @user = User.find_by_id(user_id)
      if signup || activation
        if @user
          payment = @user.payments.find(:first, :order => "id DESC")
          if membership.membership_type == "business"
            payment.update_attributes({:membership_id => membership_id, :company_id => @user.company.id, :status => Payment::STATUS[:success], :vendor => params[:vendor], :amount => membership.amount}) if payment
          else
            payment.update_attributes({:membership_id => membership_id, :status => Payment::STATUS[:success], :vendor => params[:vendor], :amount => membership.amount}) if payment
          end
          @user.update_attributes({:active => 1, :membership_id => membership_id, :next_payment_date => Time.now + 2592000, :cycle_start_date => Time.now, :uploaded_size => 0})
          Notifier.deliver_welcome!(@user)
          UserSession.create(@user, false)
        end
        flash[:notice] = "Your account has been activated successfully"
        Notification.deliver_notification("Upgrade membership",@user, { "params" => {:next_payment_date => @user.next_payment_date.strftime("%Y-%m-%d"), :now => Time.now.strftime("%Y-%m-%d"), :payment_id => payment.id, :amount => payment.amount, :user_name => @user.user_name}}, :locale => session[:locale] == "arabic")
        if membership.membership_type == "business" && ((Time.now - @user.created_at)/60 > 10) && !@user.company.blank?
          redirect_to services_company_brand_path(@user.company.id, @user.company.default_brand.id)
          return
        else
          if params[:vendor] == "cashu"
            redirect_to :action => :back_from_cashu, :to_url => url_for(back_from_cashu_user_services_path(@user, :notice => flash[:notice], :signup => true, :locale => locale, :only_path => false))#"http://edintity.com/users/#{@user.id}/services/back_from_cashu?notice=#{flash[:notice]}&signup=true&locale=#{locale}"
            return
          else
            redirect_to user_services_path(@user, :signup => true, :tab => 'services', :locale => locale)
            return
          end
        end

      else
        if @user
          from_membership_id = @user.membership_id
          if membership.membership_type == "business"
            @user.payments.create({:membership_id => membership_id, :company_id => @user.company.id,:status => Payment::STATUS[:success], :vendor => params[:vendor], :amount => membership.amount})
          else
            @user.payments.create({:membership_id => membership_id, :status => Payment::STATUS[:success], :vendor => params[:vendor], :amount => membership.amount})
          end
          @user.update_attributes({:membership_id => membership_id, :next_payment_date => @user.next_payment_date.blank? ? (Time.now + 2592000) : (@user.next_payment_date + 2592000), :cycle_start_date => Time.now, :uploaded_size => 0})
        end
        UserSession.create(@user, false)
        UserUpgrade.create({:user_id => @user.id, :company_id => membership.membership_type == "business" ? @user.company.id : nil, :from_membership_id => from_membership_id, :to_membership_id => @user.membership_id, :from_to => "#{from_membership_id}-#{@user.membership_id}"})
        flash[:notice] = "Your account has been upgraded to #{membership.name}"
        payment = @user.payments.find(:first, :order => "id DESC")
        Notification.deliver_notification("Upgrade membership",@user, { "params" => {:next_payment_date => @user.next_payment_date.strftime("%Y-%m-%d"), :now => Time.now.strftime("%Y-%m-%d"), :payment_id => payment.id, :amount => payment.amount, :user_name => @user.user_name}}, :locale => session[:locale] == "arabic")
        if params[:vendor] == "cashu"
          redirect_to :action => :back_from_cashu, :to_url => url_for(edit_user_path(@user, :notice => flash[:notice], :sessionid => params[:session_id], :locale => locale, :only_path => false))#"http://edintity.com/users/#{@user.id}/edit?notice=#{flash[:notice]}&sessionid=#{params[:session_id]}&locale=#{locale}"
          return
        else
          redirect_to :action => :edit, :locale => locale
          return
        end
      end
    end
  end

  def payment_failure
    if params[:vendor] == "paypal_credit_cards"
      ids = params["CUSTID"].split("-")
      if ids.last == "company"
        do_proceed = false
        redirect_to payment_failure_companies_path("CUSTID" => params["CUSTID"], :vendor => "paypal_credit_cards")
      else
        user_id = ids[0]
        membership_id = ids[1]
        signup = ids[2] == "true" ? true : false
        activation = ids[3] == "true" ? true : false
        locale = ids[4]
      end
    elsif params[:vendor] == "cashu"
      ids = params["txt1"].split("-")
      if ids.last == "company"
        do_proceed = false
        redirect_to payment_failure_companies_path("txt1" => params["txt1"], :vendor => "cashu")
      else
        user_id = ids[1]
        membership_id = ids[2]
        signup = ids[3] == "true" ? true : false
        activation = ids[4] == "true" ? true : false
        locale = ids[5]
      end
    else
      params[:vendor] = "paypal"
      user_id = params[:user_id] || session[:user_id]
      membership_id = params[:membership_id] || session[:membership_id]
      signup = session[:signup]
      activation = session[:activation]
      locale = session[:locale] || "en"
    end
    membership = Membership.find_by_id(membership_id)
    @user = User.find_by_id(user_id)
    if signup
      if @user
        payment = @user.payments.find(:first, :order => "id DESC")
        if membership.membership_type == "business"
          payment.update_attributes({:membership_id => membership_id, :company_id => @user.company.id,:status => Payment::STATUS[:failure], :vendor => params[:vendor], :amount => membership.amount}) if payment
        else
          payment.update_attributes({:membership_id => membership_id, :status => Payment::STATUS[:failure], :vendor => params[:vendor], :amount => membership.amount}) if payment
        end
        @user.update_attributes({:active => 0, :membership_id => 2})
        Notification.deliver_notification("Activation", @user, { "params" => {"account_activation_url" => activate_url(@user.perishable_token, :locale => session[:locale])}}, :locale => session[:locale] == "arabic")
        Notification.deliver_notification("User Creation", "", { "params" => {:user_name => @user.user_name}}, :locale => session[:locale] == "arabic")
      end
      #      flash[:notice] = "#{t :account_created}"
      if params[:vendor] == "cashu"
        redirect_to :action => :back_from_cashu, :failed => true, :to_url => url_for(login_path(:locale => locale, :notice => flash[:notice]))#"http://edintity.com/login?notice=#{flash[:notice]}&locale=#{locale}"
      else
        redirect_to login_path(:locale => locale)
      end
    elsif activation
      if @user
        payment = @user.payments.find(:first, :order => "id DESC")
        if membership.membership_type == "business"
          payment.update_attributes({:membership_id => membership_id, :company_id => @user.company.id, :status => Payment::STATUS[:failure], :vendor => params[:vendor], :amount => membership.amount}) if payment
        else
          payment.update_attributes({:membership_id => membership_id, :status => Payment::STATUS[:failure], :vendor => params[:vendor], :amount => membership.amount}) if payment
        end
      end
      flash[:notice] = "Payment failed"
      if params[:vendor] == "cashu"
        redirect_to :action => :back_from_cashu, :failed => true, :to_url => url_for(payment_activations_path(:user_id => @user.id, :notice => flash[:notice], :locale => locale, :only_path => false))#"http://edintity.com/activations/payment?user_id=#{@user.id}&notice=#{flash[:notice]}&locale=#{locale}"
      else
        redirect_to :controller => :activations, :action => :payment, :user_id => @user.id, :signup => true, :locale => locale
      end
    else
      if membership.membership_type == "business"
        @user.payments.create({:membership_id => membership_id, :company_id => @user.company.id, :status => Payment::STATUS[:failure], :vendor => params[:vendor], :amount => membership.amount}) if @user
      else
        @user.payments.create({:membership_id => membership_id, :status => Payment::STATUS[:failure], :vendor => params[:vendor], :amount => membership.amount}) if @user
      end
      flash[:notice] = "Upgradation failed. Please try again later"
      if params[:vendor] == "cashu"
        redirect_to :action => :back_from_cashu, :failed => true, :to_url => url_for(edit_user_path(@user, :notice => flash[:notice], :locale => locale, :only_path => false))#"http://edintity.com/users/#{@user.id}/edit?notice=#{flash[:notice]}&locale=#{locale}"
      else
        redirect_to :action => :edit, :locale => locale
      end
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

  def edit
    flash.now[:notice] = params[:notice] if params[:notice]
    @sessionid = params[:sessionid]
    init_edit
    @user= current_user
    @current_cycle_total_streams = @user.streams.from_services.find(:all,:conditions=>{:created_at =>@user.cycle_start_date..@user.cycle_start_date+1.month }).count
    @current_cycle_photo_streams = @user.streams.edintity_photo_streams.find(:all,:conditions=>{:created_at =>@user.cycle_start_date..@user.cycle_start_date+1.month }).count
    @current_cycle_status_streams = @user.streams.edintity_status_streams.find(:all,:conditions=>{:created_at =>@user.cycle_start_date..@user.cycle_start_date+1.month }).count
    @current_cycle_blog_streams = @user.streams.edintity_blog_streams.find(:all,:conditions=>{:created_at =>@user.cycle_start_date..@user.cycle_start_date+1.month }).count
    @current_cycle_link_streams = @user.streams.edintity_link_streams.find(:all,:conditions=>{:created_at =>@user.cycle_start_date..@user.cycle_start_date+1.month }).count
    @current_cycle_video_streams = @user.streams.edintity_video_streams.find(:all,:conditions=>{:created_at =>@user.cycle_start_date..@user.cycle_start_date+1.month }).count
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    user_email = @user.email
    if @user.update_attributes(params[:user])
      @user.user_privacy_setting.update_attribute(:full_name, params[:user_privacy_setting][:full_name])
      unless params[:user][:email] == user_email
        @user.update_attributes({:active => false})
        Notification.deliver_notification("Activation", @user, { "params" => {"account_activation_url" => activate_url(@user.perishable_token, :locale => session[:locale])}}, :locale => session[:locale] == "arabic")
        #        current_user_session.destroy
        render :update do |page|
          page << "notice(\"#{t :account_email_updated}\")"
          page << "$j('#userEmail').html('#{@user.email}')"
          page << "toggle_visibility('emailEdit');"
        end
      else
        render :update do |page|
          page << "notice(\"#{t :profile_updated}\")"
          page << "$j('#userFullname').html('#{@user.full_name}')"
          page.replace_html "update_profile", :partial => "users/profile"
        end
      end
    else
      render :update do |page|
        page << "notice(\"#{t :profile_not_updated}\")"
      end
    end
  end

  def update_password
    if current_user.valid_password?(params[:old_password])
      current_user.password = params[:password]
      current_user.password_confirmation = params[:password_confirmation]
      if current_user.update_attributes(params[:user])
        render :update do |page|
          #          page << "$j('#change_pwd_btn').show();$j('#pwd_spinner').hide();"
          page << "notice(\"#{t :pwd_updated}\")"
        end
      else
        render :update do |page|
          #          page << "$j('#change_pwd_btn').show();$j('#pwd_spinner').hide();"
          page << "notice(\"#{current_user.errors.full_messages.join('. ')}\")"
        end
      end
    else
      render :update do |page|
        #        page << "$j('#change_pwd_btn').show();$j('#pwd_spinner').hide();$('change_password_form').reset()"
        page << "notice(\"#{t :password_invalid}\")"
      end
    end
  end

  def swfupload_file(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    data
  end

  def upload
    @filename = "#{current_user.id}_#{Time.now.to_i}_#{params['qqfile']}"
    new_file = File.open('uploads/' + @filename, "wb")
    str =  request.body.read
    new_file.write(str)
    new_file.close
    upload_file = File.open("uploads/#{@filename}", "r")
    if  params[:scope] == "companies" || params[:scope] == "brands"
      if params[:company_id] && !params[:brand_id]
        @company = Company.find_by_id(params[:company_id])
        #        upload_file = swfupload_file(params[:Filedata])
        @asset = Asset.new({:asset => upload_file})
        @asset.company_id = @company.id
        @asset.user_id = params[:user_id]
      elsif params[:brand_id]
        @brand = Brand.find_by_id(params[:brand_id])
        #        upload_file = swfupload_file(params[:Filedata])
        @asset = Asset.new({:asset => upload_file})
        @asset.company_id = params[:company_id] if params[:company_id]
        @asset.user_id = params[:user_id] if params[:user_id]
        @asset.brand_id = @brand.id
      end
    else
      current_user.profile_image.destroy if current_user.profile_image
      @asset = current_user.assets.new({:asset => upload_file})
      @asset.attachable_id = current_user.id
      @asset.attachable_type = "User"
    end
    if @asset.save!
      if params[:scope] == "companies"|| params[:scope] == "brands"
        if params[:company_id]&& !params[:brand_id]
          @company.profile_image.destroy if @company.profile_image
          @asset.update_attributes(:attachable_id => @company.id, :attachable_type => "Company")
          render :partial => "companies/company_avatar"
        elsif params[:brand_id]
          @brand.profile_image.destroy if @brand.profile_image
          @asset.update_attributes(:attachable_id => @brand.id, :attachable_type => "Brand")
          render :partial => "companies/brand_avatar"
        end
      else
        @user = current_user
        @image = render_to_string :partial => "users/avatar"
        render :json => {:image => @image}, :content_type => "text/html"
      end
    end
  end

  def delete_avatar
    @user = current_user
    current_user.profile_image.destroy if current_user.profile_image
    render :partial => "users/avatar"
  end


  def user_validation
    if !params[:user_name].blank?
      params[:user_name] = params[:user_name].downcase
      format_check = params[:user_name].gsub(/^\w+$/i) do |match|
        @format_check = true
      end

      if format_check == "true"
        @existing_user = !current_user.blank? && params[:user_name].strip ==  current_user.user_name ? nil : (User.find_all_by_user_name(params[:user_name]) || Company.find_by_name(params[:company_name]))

        if user_name_filter(params[:user_name])
          render :update do |page|
            page << "$j('#user_name_check').html('#{'<span class="checkIco errorCheckIco"></span>'}#{'<div class="formError" style="display: block;"><p>'+ t(:user_name_not_allowed) +'</p></div>'}')"
            page << "$j('#user_user_name').addClass('validate_failure');"
            page.replace_html "user_url", "#{t :profile_url_text}http://UserName.edintity.com"
          end
        elsif @existing_user.blank? && (params[:company_name].downcase != params[:user_name])
          render :update do |page|
            unless params[:scope]
              page << "$j('#user_name_check').html('#{'<span class="checkIco correctCheckIco"></span>'}')"
              page << "$j('#user_user_name').removeClass('validate_failure');$j('#user_user_name').addClass('validate_success');"
            else
              if params[:user_name].strip ==  current_user.user_name
                page << "$j('#userNameValid').removeClass('hide');$j('#userNameMessage').html('#{t :this_is_you}');"
              else
                page << "$j('#userNameValid').removeClass('hide');$j('#userNameMessage').html('#{t :available}');"
              end
              page << "$j('#loadingIndiUs').addClass('hide');"
            end
          end
        else
          render :update do |page|
            unless params[:scope]
              page << "$j('#user_name_check').html('#{'<span class="checkIco errorCheckIco"></span>'}#{'<div class="formError" style="display: block;"><p>'+ t(:user_name_taken) +'</p></div>'}')"
              #            page.replace_html "user_name_check", "<div class='formError' style='display: block;'><p>User Name has already been taken</p></div>"
              page << "$j('#user_user_name').addClass('validate_failure');"
              page.replace_html "user_url", "#{t :profile_url_text}http://UserName.edintity.com"
            else
              page << "$j('#userNameInvalid').removeClass('hide');$j('#userNameMessage').html('#{t :unavailable}');"
              page << "$j('#loadingIndiUs').addClass('hide');"
            end
          end
        end
      else
        render :update do |page|
          unless params[:scope]
            page << "$j('#user_name_check').html('#{'<span class="checkIco errorCheckIco"></span>'}#{'<div class="formError" style="display: block;"><p>'+ t(:user_name_validation) +'</p></div>'}')"
            page << "$j('#user_user_name').addClass('validate_failure');"
            page.replace_html "user_url", "#{t :profile_url_text}http://UserName.edintity.com"
          else
            page << "$j('#userNameInvalid').removeClass('hide');$j('#userNameMessage').html('Unavailable');"
            page << "$j('#loadingIndiUs').addClass('hide');"
          end
        end
      end
    elsif !params[:email].blank?
      params[:email] = params[:email].downcase
      format_check = params[:email].gsub(/\b[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}\b/i) do |match|
        @format_check = true
      end
      if format_check == "true"
        @existing_user = !current_user.blank? && params[:email].strip ==  current_user.email ? nil : User.find_all_by_email(params[:email])
        if @existing_user.blank?
          render :update do |page|
            page << "$j('#email_check').html('#{'<span class="checkIco correctCheckIco"></span>'}')"
            page << "$j('#user_email').removeClass('validate_failure');$j('#user_email').addClass('validate_success');"
          end
        else
          render :update do |page|
            page << "$j('#email_check').html('#{'<span class="checkIco errorCheckIco"></span>'}#{'<div class="formError" style="display: block;"><p>'+ t(:email_taken) +'</p></div>'}')"
            #            page.replace_html "email_check", "<div class='formError' style='display: block;'><p>Email has already been taken</p></div>"
            page << "$j('#user_email').addClass('validate_failure');"
          end
        end
      else
        render :update do |page|
          page << "$j('#email_check').html('#{'<span class="checkIco errorCheckIco"></span>'}#{'<div class="formError" style="display: block;"><p>'+ t(:invalid_email_format) +'</p></div>'}')"
          #          page.replace_html "email_check", "<div class='formError' style='display: block;'><p>Invalid Email format</p></div>"
          page << "$j('#user_email').addClass('validate_failure');"
        end
      end
    else
      render :update do |page|
        page << "$j('#email_check').html('#{'<span class="correctCheckIco"></span>'}')"
        page << "$j('#user_name_check').html('#{'<span class="correctCheckIco"></span>'}')"
      end
      return
    end
  end


  def show_time_zone
    render :update do |page|
      page.replace_html "user_time_zone", select(:user, :time_zone, get_time_zones(params[:country_code]))
    end
  end

  def init_edit
    @user = current_user
    @privacy_groups = current_user.privacy_groups
    @privacy_setting = current_user.read_or_create_privacy_setting
    @stream_actions = current_user.read_or_create_stream_actions
    current_user.create_user_service_stream_actions
    @social_networking_services = Service.social_networking_services
    @video_publishing_services = Service.video_publishing_services
    @bookmarking_services = Service.bookmarking_services
    @blogging_services = Service.blogging_services
    @photo_sharing_services = Service.photo_sharing_services
    @blocked_users = current_user.blocked_users
    usage = (current_user.uploaded_size.to_i)/1024/1024.0
    @current_usage = (usage * 1000).round.to_f / 1000
    @notifications = Notification.find(:all, :conditions => {:is_displayable => true})
    load_payments
  end

  def load_payments
    @payments_table = Grid::PaymentsPresenter.new(@template)
    @payments = current_user.payments.all(:order => @payments_table.order)
    @payments = @payments.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @payments_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @payments.size)
  end

  #fifth action of signup wizard page
  def done
    @current_user.update_attribute(:done, "1")
    @current_user.update_attribute(:privacy_type_id, params[:privacy_type_id])
  end

  def update_notifications
    begin
      notifications = Notification.find(params[:user_notifications])
      current_user.notifications = notifications
      render :update do |page|
        page << "notice('Notification setting updated successfully')"
      end
    rescue
      render :update do |page|
        page << "notice('Unable to update notification setting, please try again!')"
      end
    end
  end

  def downgrade_confirm
    @header = "#{t :downgrade_to_free}"
    @days_left = (((current_user.cycle_start_date + 2592000) - Time.now)/24/60/60).to_i
    @payment_date = current_user.next_payment_date
    render :layout => 'redbox'
  end

  def free_account_confirm
    @header = "#{t :downgrade_to_free}"
    render :layout => 'redbox'
  end

  def downgrade_to_free
    days_left = (((current_user.cycle_start_date + 2592000) - Time.now)/24/60/60).to_i
    if days_left > 0
      current_user.downgrade.destroy if current_user.downgrade
      Downgrade.create({:user_id => current_user.id, :next_payment_date => current_user.next_payment_date})
      flash[:notice] = "#{t :downgraded_by, :date => current_user.next_payment_date.strftime('%d %b %Y')}"
    else
      current_user.update_attributes({:membership_id => 1, :cycle_start_date => Time.now, :uploaded_size => 0, :next_payment_date => nil, :free_user_since => Time.now})
      Notification.deliver_notification("Account Downgraded", current_user, { "params" => {}})
      flash[:notice] = "#{t :downgrade_notice}"
    end
    redirect_to :action => :edit
  end

  def upgrade_to_premium
    @membership = Membership.active.find_by_id(params[:membership_id])
    @user = current_user
    session[:membership_id] = params[:membership_id]
    session[:user_id] = current_user.id
    fetch_decrypted(@membership, current_user.id)
    @header = "#{t :upgrade_to_premium}"
    render :layout => 'redbox'
  end

  def search_user
    @users = User.get_all_users(params[:searchword]) unless params[:searchword].blank?
    @users = @users.sort { |a, b| a.created_at <=> b.created_at }
    @users = @users.paginate({ :page => params[:page], :per_page => 10}) unless @users.blank?
    if(request.xhr? && params[:ajax_search] == 'true')
      render :update do |page|
        page.replace_html "body_content_mid", :partial => "ajax_search_results"
        page << "$('email_form').innerHTML = htmlContent;"
      end
    elsif(request.xhr? &&  params[:pagination] == "true")
      render :update do |page|
        page.replace_html "pagination", :partial => "ajax_search_results"
      end
    elsif(request.xhr?)
      render :layout =>false
    else
      @ajax = false
    end
  end

  def more_users
    @users = User.get_all_users(params[:searchword]) unless params[:searchword].blank?
    @users = @users.sort { |a, b| a.created_at <=> b.created_at }
    @users = @users.paginate({ :page => params[:current_page], :per_page => 10}) unless @users.blank?
    render :update do |page|
      page.insert_html :bottom, 'userList', :partial => "users/more_users", :locals => {:users => @users, :current_page => params[:current_page].to_i}
    end
  end

  def search_user_from_header
    @users =  User.find(:all, :include => [:user_privacy_setting], :conditions => ['user_name LIKE ? AND user_privacy_settings.is_searchable = 1', "#{params[:searchword]}%"], :order => 'user_name', :limit => 5) unless params[:searchword].blank?
    @topics = Topic.find(:all,:conditions=>['title LIKE ?',"#{params[:searchword]}%"], :order => 'title', :limit => 5) unless params[:searchword].blank?
    # = current_user.streams.find_by_topic_id(params[:topic_id])
    #@companies = Brand.find(:all, :include => [:brand_privacy], :conditions => ['name LIKE ? AND brand_privacies.is_searchable = 1', "#{params[:searchword]}%"], :order => 'name', :limit => 5) unless params[:searchword].blank?
    #    @users = User.get_all_users(params[:searchword]) unless params[:searchword].blank?
    @users = @users.paginate({ :page => params[:page], :per_page => 10}) unless @users.blank?
    #@companies = @companies.paginate({ :page => params[:page], :per_page => 10}) unless @companies.blank?
    render :update do |page|
      page.replace_html "searchDropdown", :partial => "users/searched_users"
    end
  end

end


