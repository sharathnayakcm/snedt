class Admin::NotificationsController < ApplicationController
  before_filter :require_user
  before_filter :admin_required

  def index
    load_notifications
    render :layout => false if request.xhr?
  end

  def show
    @notification = Notification.find(params[:id])
  end

  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.new(params[:notification])
    if @notification.save
      redirect_to admin_notifications_path(current_user)
    else

      render :new
    end
  end

  def edit
    @notification = Notification.find(params[:id])
  end

  def update
    @notification = Notification.find(params[:id])
    if @notification.update_attributes(params[:notification])
      redirect_to admin_notifications_path(current_user)
    else
      render :edit
    end
  end

  def destroy
    @notification = Notification.find(params[:id])
    if @notification.destroy
      render :update do |page|
        page << "Effect.Fade('notification_#{@notification.id}')"
        page << "notice('Notification deleted successfully')"
      end
    else
      render :update do |page|
        page << "notice('Unable to delete Notification, please try again!')"
      end
    end
  end

  private

  def load_notifications
    @notifications_table = Grid::Admin::NotificationsPresenter.new(@template)
    @notifications = Notification.all(:conditions => ["is_notification = true"], :order => @notifications_table.order)
    @notifications = @notifications.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @notifications_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @notifications.size)
  end

end
