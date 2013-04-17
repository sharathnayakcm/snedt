class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user

  def index
  end

  def show
  end

  def new
  end
  
  def create
    @user = User.find_by_email(params[:email])
    if @user
      #TODO: New notification method has to be used as below.
      # Notification.deliver_notification("Reset Password", @user, {"params" => {}}, session[:locale] == "arabic")
      Notifier.deliver_password_reset_instructions!(@user)
      flash[:notice] = "#{t 'pwd_reset_instruction_emailed'} "
      if request.xhr?
        render :update do |page|
          page << "notice('Password reset email deliverd to #{params[:email]}')"
        end
      else
        redirect_to login_path
      end
    else
      if request.xhr?
        render :update do |page|
          page << "#{t 'no_user_found'}"
        end
      else
        flash[:notice] = "#{t 'no_user_found'}"
        render :action => :new
      end
    end
  end
  
  def edit
    render
  end

  def update
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    if @user.save
      flash[:notice] = "#{t 'pwd_updated'}"
      redirect_to root_url
    else
      msg = []
      if RAILS_ENV == "production"
        msg = @user.errors.full_messages
      else
        @user.errors.each do |error|
          msg << "#{error.first} #{error.last}"
        end
      end

      flash[:notice] = msg.join("<br />")
      render :action => :edit
    end
  end

  private
  def load_user_using_perishable_token
    @user = User.find_by_perishable_token(params[:id])
    unless @user
      flash[:notice] = "#{t 'could_not_locate_account'}"
      redirect_to root_url
    end
  end
end
