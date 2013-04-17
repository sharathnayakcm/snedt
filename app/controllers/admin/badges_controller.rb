class Admin::BadgesController < ApplicationController
  before_filter :require_user
  before_filter :admin_required
  
  def index
    load_badges
    render :layout => false if request.xhr?
  end

  # GET /badges/1
  # GET /badges/1.xml
  def show
    @badge = Badge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @badge }
    end
  end

  # GET /badges/new
  # GET /badges/new.xml
  def new
    @badge = Badge.new
  end

  # GET /badges/1/edit
  def edit
    @badge = Badge.find(params[:id])
  end

  # POST /badges
  # POST /badges.xml
    def create
    @badge = Badge.new(params[:badge])
    if @badge.save
      @asset = Asset.new({:asset => params[:asset][:file], :user_id => current_user.id, :attachable_id => @badge.id, :attachable_type => "badge"})
      @asset.save
      flash[:notice] = "Successfully created badge."
      redirect_to admin_badges_path(current_user)
    else
      render :action => 'new'
    end
  end


  # PUT /badges/1
  # PUT /badges/1.xml
  def update
    @badge = Badge.find(params[:id])
    if @badge.update_attributes(params[:badge])
      if @badge.asset
        @badge.asset.update_attributes({:asset => params[:asset][:file], :attachable_id => @badge.id, :attachable_type => "badge"})
      else
        @asset = Asset.new({:asset => params[:asset][:file], :user_id => current_user.id, :attachable_id => @badge.id, :attachable_type => "badge"})
        @asset.save
      end
      flash[:notice] = "Successfully updated badge."
      redirect_to admin_badges_path(current_user)
    else
      render :action => 'edit'
    end
  end


  # DELETE /badges/1
  # DELETE /badges/1.xml
  def destroy
    @badge = Badge.find(params[:id])
    @badge.destroy
    if @badge.destroy
      render :update do |page|
        page << "Effect.Fade('badge_#{@badge.id}')"
        page << "notice('badge deleted successfully')"
      end
    else
      render :update do |page|
        page << "notice('Unable to delete badge, please try again!')"
      end
    end
  end

  private

  def load_badges
    @badges_table = Grid::Admin::BadgesPresenter.new(@template)
    @badges = Badge.all(:order => @badges_table.order)
    @badges = @badges.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @badges_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @badges.size)
  end
end
