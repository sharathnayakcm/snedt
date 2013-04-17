class Admin::SiteConfigurationsController < ApplicationController
    before_filter :require_user
  before_filter :admin_required

  def index
    load_site_configurations
    render :layout => false if request.xhr?
  end

  def show
    @site_configuration = SiteConfiguration.find(params[:id])
  end

  def new
    @site_configuration = SiteConfiguration.new
  end

  def create
    @site_configuration = SiteConfiguration.new(params[:site_configuration])
    if @site_configuration.save
      redirect_to admin_site_configurations_path(current_user)
    else

      render :new
    end
  end

  def edit
    @site_configuration = SiteConfiguration.find(params[:id])
  end

  def update
    @site_configuration = SiteConfiguration.find(params[:id])
    if @site_configuration.update_attributes(params[:site_configuration])
      redirect_to admin_site_configurations_path(current_user)
    else
      render :edit
    end
  end

  def destroy
    @site_configuration = SiteConfiguration.find(params[:id])
    if @site_configuration.destroy
      render :update do |page|
        page << "Effect.Fade('site_configuration_#{@site_configuration.id}')"
        page << "notice('SiteConfiguration deleted successfully')"
      end
    else
      render :update do |page|
        page << "notice('Unable to delete SiteConfiguration, please try again!')"
      end
    end
  end

  private

  def load_site_configurations
    @site_configurations_table = Grid::Admin::SiteConfigurationsPresenter.new(@template)
    @site_configurations = SiteConfiguration.all(:order => @site_configurations_table.order)
    @site_configurations = @site_configurations.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @site_configurations_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @site_configurations.size)
  end

end
