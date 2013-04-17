class ActivationsController < ApplicationController
  #before_filter :require_no_user
  include UserHelper

  def create
    @user = User.find_using_perishable_token(params[:activation_code], 1.week)# || (raise Exception)
    if ((@user) and (!@user.is_active?)) # if user exists and user is not yet active and user activation of user is successful
      @user.activate!
      Activity.add_points(@user, Activity::ACTIVITY_TYPES[:activate], 'User', @user.id)
      flash[:notice] = "#{t 'account_activated'}"
      session[:activation_reminder] = false
      UserSession.create(@user, false) # Log user in manually
      if @user.done
        redirect_to root_path
      else
#        Notifier.deliver_welcome!(@user)
        Notification.deliver_notification("Signup", @user, { "params" => {}}, :locale => session[:locale] == "arabic")
=begin
        if @user.membership_id == 1 || @user.membership_id == 3
#          redirect_to user_services_path(@user, :signup => true, :tab => 'services')
            render :action => :create
        else
          redirect_to :action => :payment, :user_id => @user.id, :signup => true
        end
=end
        if @user.payments.nil? || !@user.payments.pending_payments.blank?
          redirect_to :action => :payment, :user_id => @user.id, :signup => true
        else
          render :action => :create
        end
      end
    elsif (@user && @user.is_active?)
      flash[:notice] = "#{t 'email_is_reset'}"
      redirect_to root_path
    else
      flash[:notice] = "#{t 'activation_link_invalid'}" unless @user
      redirect_to login_path
    end
  end

  def payment
    @user = User.find_by_id(params[:user_id])
    @membership = @user.membership
    session[:signup] = @activation = true
    fetch_decrypted(@membership, params[:user_id])
  end

  def free_account_confirm
    @header = "Downgrade to Free"
    render :layout => 'redbox'
  end

  def free_account
    if current_user
      current_user.update_attributes({:membership_id => 1, :free_user_since => Time.now})
      flash[:notice] = "Your account has been downgraded to free"
      redirect_to user_services_path(current_user, :signup => true, :tab => 'services')
    else
      redirect_to login_path
    end
  end

  def edit
  end

  def update
    @user = User.find_by_email(params[:email])
    if @user
      Notifier.deliver_activation_instructions!(@user)
      flash[:notice] = "#{t 'account_activation_instruction_emailed'}"
      redirect_to login_path
    else
      flash[:notice] = "#{t 'no_user_found'}"
      render :action => :edit
    end
  end

  def resend
    Notification.deliver_notification("ActivationPending", current_user, { "params" => {"receipient_name" => current_user.user_name, "account_activation_url" => activate_url(current_user.perishable_token)}}, "true")
    #Notifier.deliver_activation_instructions!(current_user)
    flash[:notice] = "#{t 'account_activation_instruction_emailed'}"
    redirect_to root_path
  end

end
