class Admin::SubscriptionsController < ApplicationController
  before_filter :require_user
  before_filter :admin_required

  def index
    load_subscriptions
    render :layout => false if request.xhr?
  end

  def destroy
    membership = Membership.find(params[:id])
    membership.destroy
    render :update do |page|
      page << "Effect.Fade('subscription_#{membership.id}')"
    end
  end

  def edit
    @subscription = Membership.find(params[:id])
  end
  
  def update
    @subscription = Membership.find(params[:id])
    if @subscription.update_attributes(params[:membership])
      redirect_to admin_subscriptions_path(current_user)
    else
      render :edit
    end
  end

  def new
    @subscription = Membership.new
  end

  def create
    @subscription = Membership.new(params[:membership])
    if @subscription.save
      redirect_to admin_subscriptions_path(current_user)
    else
      render :new
    end
  end

  private

  def load_subscriptions
    @subscriptions_table = Grid::Admin::SubscriptionsPresenter.new(@template)
    @subscriptions = Membership.all(:order => @subscriptions_table.order)
  end
end
