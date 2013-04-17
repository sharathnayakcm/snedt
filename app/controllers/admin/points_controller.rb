class Admin::PointsController < ApplicationController
  before_filter :require_user
  before_filter :admin_required
  
  def index
    load_points
    render :layout => false if request.xhr?
  end

  # GET /points/1
  # GET /points/1.xml
  def show
    @point = Point.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @point }
    end
  end

  # GET /points/new
  # GET /points/new.xml
  def new
    @point = Point.new
  end

  # GET /points/1/edit
  def edit
    @point = Point.find(params[:id])
  end

  # POST /points
  # POST /points.xml
    def create
    @Point = Point.new(params[:point])
    if @Point.save
      flash[:notice] = "Successfully created point."
      redirect_to admin_points_path(current_user)
    else
      render :action => 'new'
    end
  end


  # PUT /points/1
  # PUT /points/1.xml
  def update
    @point = Point.find(params[:id])
    if @point.update_attributes(params[:point])
      flash[:notice] = "Successfully updated point."
      redirect_to admin_points_path(current_user)
    else
      render :action => 'edit'
    end
  end


  # DELETE /points/1
  # DELETE /points/1.xml
  def destroy
    @point = Point.find(params[:id])
    @point.destroy
    if @point.destroy
      render :update do |page|
        page << "Effect.Fade('point_#{@point.id}')"
        page << "notice('point deleted successfully')"
      end
    else
      render :update do |page|
        page << "notice('Unable to delete point, please try again!')"
      end
    end
  end

  private

  def load_points
    @points_table = Grid::Admin::PointsPresenter.new(@template)
    @points = Point.all(:order => @points_table.order)
    @points = @points.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @points_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @points.size)
  end
end
