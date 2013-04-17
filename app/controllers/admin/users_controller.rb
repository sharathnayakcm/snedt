class Admin::UsersController < AdminController
  before_filter :require_user
  before_filter :admin_required

  def index
    load_users
    respond_to do |format|
      format.csv do
        @users = User.all(:order => @users_table.order)
        csv_string = FasterCSV.generate do |csv|
          csv << ['Full Name','User Name','Email','Membership','Last Login','Services','Pending Services','Member Since','Status']
          @users.each do |user|
            csv << [user.full_name, user.user_name,user.email,"#{user.membership ? user.membership.name : ''}", user.last_login, user.user_services.count, user.pending_services.count, user.created_at.strftime("%d %b %Y"), user.active ? 'Active' : 'Inactive']
          end
        end
        send_data csv_string, :type => "text/csv",:filename=>"edintity_users_#{Time.now.to_i}.csv", :disposition => 'attachment'
      end
      format.js do
        render :layout => false
      end
      format.html
    end    
  end

  def new
    @user = User.new
    #    @timezone = TimeZone.new()
    #    raise @timezone.inspect
  end

  def create
    @user = User.new(params[:user])
    @user.status = "1"
    @user.privacy_type_id = 1
    if @user.save && @user.save_without_session_maintenance
      Notifier.deliver_activation_instructions(@user)
      flash[:notice] = "#{t :account_created}"
      redirect_to admin_users_path
    else
      render :action => :new
    end
  end

  def edit
    @user = User.find(params[:id])
    init_edit
  end

  def update
    @user = User.find(params[:id])
    user_previous_email = @user.email
    if @user.update_attributes(params[:user])
      flash[:notice] = "#{t :user_updated}"
      unless params[:user][:email] == user_previous_email
        Notifier.deliver_activation_instructions(@user)
        flash[:notice] = "#{t :activation_success}"
      end
      redirect_to admin_users_path(current_user)
    else
      init_edit
      flash[:notice] = "#{t :user_not_updated}"
      render :action => :edit
    end

  end

  def user_validation
    unless params[:user_name].blank?
      @existing_user = User.find_all_by_user_name(params[:user_name])
      if @existing_user.blank?
        render :text => false, :layout => false
      else
        render :text => true, :layout => false
      end
    else
      render :text => 'blank', :layout => false
    end
    return
    if params[:password]
      @existing_user = User.find_all_by_user_name(params[:password])
      if @existing_user.blank?
        @validate_user_status = "<font color='green'><b>#{t :incorrect_pwd}</b></font>"
      else
        @validate_user_status = "<font color='green'><b>#{t :correct_pwd}</b></font>"
      end
    end
    render :layout => false
  end

  def init_edit
  end

  #fifth action of signup wizard page
  def done
    @current_user.update_attribute(:done, "1")
    @current_user.update_attribute(:privacy_type_id, params[:privacy_type_id])
  end

  def toggle_active
    user = User.find(params[:id])
    user.toggle!(:active)
    user.update_attribute(:deleted_at, nil) if user.active
    render :update do |page|
      page.replace_html "user_deleted_#{user.id}", ""
      page << "notice('Status updated successfully')"
    end
  end

  def reset_password
    @user = User.find_by_email(params[:email])
    if @user
      #TODO: New notification method has to be used as below.
      # Notification.deliver_notification("Reset Password", @user, {"params" => {}}, session[:locale] == "arabic")
      Notifier.deliver_password_reset_instructions!(@user)
      render :update do |page|
        page << "notice('#{t 'pwd_reset_instruction_emailed'} #{params[:email]}')"
      end
    else
      render :update do |page|
        page << "#{t 'no_user_found'}"
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.update_attributes(:deleted_at => Time.now, :active => false)
    render :update do |page|
      page.replace_html "user_deleted_#{@user.id}", (to_local(@user.deleted_at).strftime("%d %b %Y"))
      page.replace_html "user_status_#{@user.id}", check_box_tag("active", @user.active, false, :onchange => toggle_status(@user))
    end
  end

  private


  def load_users
    @users_table = Grid::Admin::UsersPresenter.new(@template)
    if params[:search_key].blank?
      @users = User.all(:order => @users_table.order)
    else
      @users = User.find(:all, :conditions => ["user_name like ? OR email like ? OR full_name like ?", "#{params[:search_key]}%", "#{params[:search_key]}%", "#{params[:search_key]}%"], :order => @users_table.order)
    end
    @users = @users.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @users_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @users.size)
  end

end


