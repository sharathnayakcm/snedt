class Users::FriendsController < ApplicationController
  before_filter :require_user

  def new
    unless params[:scope]
      @signup_page = params[:signup] ? true : false
      @friend = Friend.new
    else
      active_company
      @company = Company.find(params[:company_id]) unless params[:company_id].blank?
    end
  end

  def create
    @user = current_user
    @user.update_attributes(:status => "3")
    redirect_to new_user_privacy_path
  end

  def find_friends
    begin
      @company = Company.find_by_id(params[:company_id]) unless params[:company_id].blank?
      contacts = []
      case params[:email_host]
      when 'gmail'
        contacts = Contacts::Gmail.new("#{params[:email]}@#{params[:email_host]}.com", params[:password]).contacts
      when 'yahoo'
        contacts = Contacts::Yahoo.new("#{params[:email]}@#{params[:email_host]}.com", params[:password]).contacts
      when 'hotmail'
        contacts = Contacts::Hotmail.new("#{params[:email]}@#{params[:email_host]}.com", params[:password]).contacts
      when 'aol'
        contacts = Contacts::Aol.new("#{params[:email]}@#{params[:email_host]}.com", params[:password]).contacts
      when 'plaxo'
        contacts = Contacts::Plaxo.new("#{params[:email]}@#{params[:email_host]}.com", params[:password]).contacts
      end
      @contact_emails = contacts.collect{|c| c.last unless(c.last == current_user.email)}
      @available_users = User.find_all_by_email(@contact_emails, :select => "email", :conditions => ["email not in (?)", current_user.email]).collect{|u| u.email}
      @users = User.find_all_by_email(@contact_emails, :conditions => ["email not in (?) and friends_find != false", current_user.email])
      @blocked_emails = User.find(:all, :select => "email", :conditions => ["friends_find = false"]).collect{|u| u.email}
      @contact_emails = @contact_emails - @available_users - @blocked_emails
      unless params[:scope]
        render :update do |page|
          page << "$('email_form').innerHTML = htmlContent;"
          page.replace_html 'contact_list', :partial => 'users/friends/search_email_result', :locals => {:contact_list => contacts}
          page << "$('email').value = '';"
          page << "$('password').value = '';"
        end
      else
        render :update do |page|
          page << "$('email_form').innerHTML = htmlContent;"
          page.replace_html 'contact_list', :partial => 'companies/contact_list', :locals => {:contact_list => contacts}
          page << "$('email').value = '';"
          page << "$('password').value = '';"
        end
      end
    rescue Exception => e
      render :update do |page|
        page << "$('email_form').innerHTML = htmlContent;"
        page << "notice('#{t :invalid_name_or_pwd}')"
        page.replace_html 'contact_list',  ''
        page << "$('email').value = '';"
        page << "$('password').value = '';"
      end
    end
  end
  
  def invite_friends
    if params[:email]
      Notifier.deliver_invite_friend(params[:email], current_user)
      Activity.add_points(current_user, Activity::ACTIVITY_TYPES[:invite], 'User', current_user.id)
      render :update do |page|
        page << "notice('Your invitation has been sent to #{params[:email]}')"
        page.replace_html "email_brand_invite_#{params[:id]}", "<div class='greenBtn flRight'><a class='smlrBtn' href='javascript:void(0)'>Invited</a></div>"
      end
    else
      unless params[:invites].blank?
        render :update do |page|
          params[:invites].each do |friend|
            Notifier.deliver_invite_friend(friend.last, current_user)
            page.replace_html "invite_status_#{friend.first}", "<font color='green'>Invited</font>"
            page << "$('invite_#{friend.first}').disabled = true;"
          end
        end
      else
        render :update do |page|
          page << "notice('#{t :select_atleast_a_contact}');"
        end
      end
    end
  end

  def search_friends
    @company = Company.find_by_id(params[:company_id]) unless params[:company_id].blank?
    @users = User.get_all_users(params[:keyword]) unless params[:keyword].blank?
    render :update do |page|
      page.replace_html "contact_list", :partial => "users/friends/search_edintity_result"
    end
  end

  def add_friends
    unless params[:friends].blank?
      render :update do |page|
        params[:friends].each do |friend|
          follower = Follower.create(:follower_id => current_user.id, :user_id => friend)
          image_url = follower.following_user.profile_image.blank? ? "http://edintity.com/avatars/original/missing.png" : follower.following_user.profile_image.asset.url.gsub("/s3.","/s3-eu-west-1.")
          Notification.deliver_notification("Follows", follower.user, { "params" => {"friend_profile_url" => url_for(profiles_path(:id => follower.following_user.user_name, :only_path => false )), "image_url" => image_url, "user_name" => follower.following_user.user_name}}, :locale => session[:locale] == "arabic") if follower.user.is_notifiable?("Follows")
          page.replace_html "followed_status_#{friend}", :partial => "unfollow_link", :locals => {:current_user => current_user, :friend => friend}
          page << "$('friend_#{friend}').disabled = true;"
          page << "$('friend_#{friend}').checked = false;"
        end

      end
    else
      render :update do |page|
        page << "notice('#{t :select_atleast_a_friend}');"
      end
    end
  end
  

  def unfollow
    follower = User.find(params[:follower])
    following = Follower.find_by_user_id_and_follower_id(params[:follower], params[:user_id])
    following.destroy if following
    if params[:scope] == "search"
      render :update do |page|
        page.replace_html "user_follow_unfollow_#{follower.id}", link_to_remote_with_loader("#{t :follow}", {:url => "/profiles/follow/#{follower.id}?scope=search"}, :method => :get, :class => "smlrBtn")
        page << "$j('#user_follow_unfollow_#{follower.id}').removeClass('yellowBtn');$j('#user_follow_unfollow_#{follower.id}').addClass('blueBtn');"
      end
    else
      render :update do |page|
        page.replace_html "on_edintity_#{params[:follower]}", :partial => "users/friends/edintity_users", :locals => {:user => follower}
        page << "notice('You are no longer following #{follower.user_name}.');"
      end
    end
  end

  def follow
    follower = User.find(params[:follower])
    if follower
      Follower.create(:follower_id => current_user.id, :user_id => params[:follower])
      image_url = follower.profile_image.blank? ? "http://edintity.com/avatars/original/missing.png" : follower.profile_image.asset.url.gsub("/s3.","/s3-eu-west-1.")
      Notification.deliver_notification("Follows", follower, { "params" => {"friend_profile_url" => url_for(profiles_path(:id => follower.user_name, :only_path => false )), "image_url" => image_url, "user_name" => follower.user_name}}, :locale => session[:locale] == "arabic") if follower.is_notifiable?("Follows")
      render :update do |page|
        page.replace_html "on_edintity_#{params[:follower]}", :partial => "users/friends/edintity_users", :locals => {:user => follower}
        page << "notice('You are now following #{follower.user_name}.');"
      end
    else
      render :update do |page|
        page << "notice('No user found');"
      end
    end
  end


  def add_friends_from_contacts
    unless params[:invites].blank?
      render :update do |page|
        params[:invites].each do |friend|
          follower = User.find_by_email(friend.last)
          unless follower.blank?
            current_user.followers.create(:follower_id => follower.id)
            page.replace_html "followed_status_#{friend.first}", "<font color='green'>Following</font>"
            page << "$('friend_#{friend.first}').disabled = true;"
          else
            page.replace_html "followed_status_#{friend.first}", "<font color='red'>Failed</font>"
          end
        end

      end
    else
      render :update do |page|
        page << "notice('#{t :select_atleast_a_friend}');"
      end
    end
  end

  def invite_friends_to_brand
    @invitee = User.find(params[:follower])
    brand = Brand.find(params[:brand_id])
    @company =  brand.company
    brand_user_group = brand.create_affiliation(@invitee, params[:access_type_id])
    message = "Affiliate invited successfull"
    if brand_user_group
      Notification.deliver_notification("AffiliationInvitation", @invitee, { "params" => {"confirm_url" => url_for(confirm_reqeust_company_brand_user_groups_path(brand.company, :brand_id => brand.id, :only_path => false)), "company_name" => brand.company.name, "brand_name" => brand.name, "company_url" => url_for(company_path(brand.company.name, :only_path => false)), "role" => BrandUserGroup::ACCESS_TYPES.index(params[:access_type_id].to_i), "responsibilities" => brand_role_responsibilities(params[:access_type_id].to_i)}}, :locale => session[:locale] == "arabic")
    else
      message = "User already affiliated"
    end

    render :update do |page|
      page << "notice('#{message}')"
      if !@company.is_allowed_to_add_user_group?
        page << "$j('.brand_invite_btn').html('<div class=\"blueBtn flRight\">#{link_to(t(:invite), "javascript:void(0)", :class => "smlrBtn", :title => "You have exceed your invite limit, please upgrade your account to inivite unlimited users", :onclick => "alert(\"You have exceed your invite limit, please upgrade your account to inivite unlimited users\")")}</div>');"
      end
      page.replace_html "brand_invite_#{@invitee.id}", "<div class='greenBtn flRight'><a class='smlrBtn' href='javascript:void(0)'>Invited</a></div>"
    end
  end

  private

  def brand_role_responsibilities(role_id)
    case role_id
    when BrandUserGroup::ACCESS_TYPES["Brand Admin"]
      "1. Manage Brands<br />2.Manage Services of all brands<br />3. Manage Users of the company<br />4. Manage Content"
    when BrandUserGroup::ACCESS_TYPES["Brand Manager"]
      "1. Manage Services of brand and sub-brands<br />2. Manage content of brands and sub-brands"
    when BrandUserGroup::ACCESS_TYPES["Content Manager"]
      "1. Manage content of the assigned brand"
    end
  end

end
