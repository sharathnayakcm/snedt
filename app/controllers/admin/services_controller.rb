class Admin::ServicesController < ApplicationController
  before_filter :require_user
  before_filter :admin_required

  def index
    load_services
    render :layout => false if request.xhr?
  end

  def show
    @service = Service.find(params[:id])
  end

  def new
    @service = Service.new
  end

  def create
    @service = Service.new(params[:service])
    @service_configuration_ids = params[:service_configurations]
    @service.service_configuration_ids = params[:service_configurations].blank? ? "" : params[:service_configurations].join(",")
    if @service.save
      redirect_to admin_services_path(current_user)
    else
      
      render :new
    end
  end

  def edit
    @service = Service.find(params[:id])
    @service_configuration_ids = @service.service_configuration_ids.blank? ? [] : @service.service_configuration_ids.split(",")
  end

  def update
    @service = Service.find(params[:id])
    @service_configuration_ids = params[:service_configurations]
    @service.service_configuration_ids = params[:service_configurations].blank? ? "" : params[:service_configurations].join(",")
    if @service.update_attributes(params[:service])
      redirect_to admin_services_path(current_user)
    else
      render :edit
    end
  end

  def destroy
    @service = Service.find(params[:id])
    if @service.destroy
      render :update do |page|
        page << "Effect.Fade('service_#{@service.id}')"
        page << "notice('Service deleted successfully')"
      end
    else
      render :update do |page|
        page << "notice('Unable to delete Service, please try again!')"
      end
    end
  end

  private

  def load_services
    @services_table = Grid::Admin::ServicesPresenter.new(@template)
    @services = Service.all(:include => [:service_category], :order => @services_table.order)
    @services = @services.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @services_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @services.size)
  end

end
