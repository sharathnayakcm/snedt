class Admin::StaticPagesController < ApplicationController
  before_filter :require_user
  before_filter :admin_required
  def index
    load_static_pages
    render :layout => false if request.xhr?
  end

  def show
    @static_page = StaticSiteContent.find(params[:id])
  end

  def new
    @static_page = StaticSiteContent.new
  end

  def create
    @static_page = StaticSiteContent.new(params[:static_site_content])
    if @static_page.save
      redirect_to admin_static_page_path(current_user, :id => @static_page.id)
    else
      render :new
    end
  end

  def edit
    @static_page = StaticSiteContent.find(params[:id])
  end

  def update
    @static_page = StaticSiteContent.find(params[:id])
    if @static_page.update_attributes(params[:static_site_content])
      redirect_to admin_static_page_path(current_user, :id => @static_page.id)
    else
      render :edit
    end
  end

  def destroy

  end

  private

  def load_static_pages
    @static_pages_table = Grid::Admin::StaticPagesPresenter.new(@template)
    @static_pages = StaticSiteContent.all(:order => @static_pages_table.order)
    @static_pages = @static_pages.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @static_pages_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @static_pages.size)
  end
end
