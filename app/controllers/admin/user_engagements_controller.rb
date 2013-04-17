class Admin::UserEngagementsController < ApplicationController
   before_filter :require_user
  before_filter :admin_required

  def index
    load_engagements
    render :layout => false if request.xhr?
  end

  def show
    @engagement = Notification.find(params[:id])
  end

  def new
    @engagement = Notification.new
  end

  def create
    @engagement = Notification.new(params[:notification])
    @engagement.is_notification = false
    @engagement.is_displayable = false
    if @engagement.save
      redirect_to admin_user_engagements_path(current_user)
    else

      render :new
    end
  end

  def edit
    @engagement = Notification.find(params[:id])
  end

  def update
    @engagement = Notification.find(params[:id])
    if @engagement.update_attributes(params[:notification])
      redirect_to admin_user_engagements_path(current_user)
    else
      render :edit
    end
  end

  def destroy
    @engagement = Notification.find(params[:id])
    if @engagement.destroy
      render :update do |page|
        page << "Effect.Fade('engagement_#{@engagement.id}')"
        page << "notice('Notification deleted successfully')"
      end
    else
      render :update do |page|
        page << "notice('Unable to delete Notification, please try again!')"
      end
    end
  end

  private

  def load_engagements
    @engagements_table = Grid::Admin::NotificationsPresenter.new(@template, {}, "user_engagement")
    @engagements = Notification.all(:conditions => ["is_notification is null or is_notification = false"], :order => @engagements_table.order)
    @engagements = @engagements.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @engagements_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @engagements.size)
  end

end
