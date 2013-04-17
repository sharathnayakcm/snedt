class Admin::TopicsController < ApplicationController
  before_filter :require_user
  before_filter :admin_required
  
  def index
    load_topics
    render :layout => false if request.xhr?
  end

  def show
    @topic = Topic.find(params[:id])
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      @asset = Asset.new({:asset => params[:asset][:file], :user_id => current_user.id, :attachable_id => @topic.id, :attachable_type => "Topic"})
      @asset.save
      flash[:notice] = "Successfully created topic."
      redirect_to admin_topics_path(current_user)
    else
      render :action => 'new'
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      if @topic.asset
        @topic.asset.update_attributes({:asset => params[:asset][:file], :attachable_id => @topic.id, :attachable_type => "Topic"})
      else
        @asset = Asset.new({:asset => params[:asset][:file], :user_id => current_user.id, :attachable_id => @topic.id, :attachable_type => "Topic"})
        @asset.save
      end
      flash[:notice] = "Successfully updated topic."
      redirect_to admin_topics_path(current_user)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
#    @topic.destroy
#    flash[:notice] = "Successfully destroyed topic."
#    redirect_to topics_url
    if @topic.destroy
      render :update do |page|
        page << "Effect.Fade('topic_#{@topic.id}')"
        page << "notice('Topic deleted successfully')"
      end
    else
      render :update do |page|
        page << "notice('Unable to delete Topic, please try again!')"
      end
    end
  end

  private

  def load_topics
    @topics_table = Grid::Admin::TopicsPresenter.new(@template)
    @topics = Topic.all(:order => @topics_table.order)
    @topics = @topics.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @topics_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @topics.size)
  end
end
