class PostServiceGroupsController < ApplicationController

  def index
    load_instances
    render :layout => false if request.xhr?
  end

  def new
    @pick_types =  PostType.find(:all)
  end

  def create
    @post_service_groups = current_user.post_service_groups
    begin
      psg =  current_user.post_service_groups.create(:name => params[:pg_name], :user_service_ids => params[:serviceid].to_a.join(","), :post_type_id => params[:type])
      if psg.save
        load_instances
        render :update do |page|
          page.replace_html "form_content", :partial => "post_service_groups/new"
          page.replace_html "post_service_group_list", :partial => "post_service_groups/post_service_group_list"
          page << "$j('#spinner_tag').hide();"
          page << "$j('#psg_count').html(#{current_user.post_service_groups.count});"
          page << "notice('Post Service Group saved successfully')"
        end
      else
        render :update do |page|
          page << "$j('#spinner_tag').hide();"
          page << "notice('Post service group name should be unique')"
        end
      end
    rescue Exception => e
      render :update do |page|
        page << "notice('Post Service group not created. Please select services')"
        page << "$j('#spinner_tag').hide();"
      end
    end
  end

  def load_service_list
    type =  PostType.find_by_id(params[:type])
    @post_service_group = current_user.post_service_groups.find_by_id(params[:id])
    get_services(type) if type
    render :update do |page|
      page.replace_html 'service_list', :partial => "post_service_groups/services_list"
      page << "$j('#service_list').show();"
    end
  end

  def edit
    @post_service_group = PostServiceGroup.find(params[:id])
    @pick_types =  PostType.find(:all)
    render :layout => false
  end

  def update_form
    @post_service_group =  current_user.post_service_groups.find_by_id(params[:id])
    @post_service_groups =  current_user.post_service_groups
    @pick_types =  PostType.find(:all)
    begin
      if @post_service_group
        @post_service_group.user_service_ids = params[:serviceid].to_a * ","
        @post_service_group.post_type_id = params[:type]
        @post_service_group.name = params[:pg_name]
        @post_service_group.save
      end
      load_instances
      render :update do |page|
        page.replace_html "form_content", :partial => "post_service_groups/new"
        page.replace_html "post_service_group_list", :partial => "post_service_groups/post_service_group_list"
        page << "$j('#spinner_tag').hide();"
        page << "$j('#pick_services').hide();"
        page << "$j('#psg_count').html(#{current_user.post_service_groups.count});"
        page << "notice('Post Service Group updated successfully')"

      end
    rescue Exception => e
      render :update do |page|
        page << "notice('Post Service group not updated. Please try agian')"
        page << "$j('#spinner_tag').hide();"
      end
    end
  end

  def destroy
    @post_service_group = current_user.post_service_groups.find(params[:id])
    @post_service_group.destroy if @post_service_group
    flash[:notice] = "Post Service Group deleted successfully."
    redirect_to root_url
  end

  def delete_confirm
    @group_id = params[:id]
    @header = "Delete Post Service Group"
    render :layout => 'redbox'
  end

  def delete
    post_service_group = current_user.post_service_groups.find_by_id(params[:id])
    post_service_group.destroy
    load_instances
    render :update do |page|
      page << "RedBox.close();"
      page << "$j('#psg_count').html(#{@post_service_groups.count});"
      page << "notice('Post Service Group deleted successfully')"
      page << "Effect.Fade('post_service_group_#{post_service_group.id}')"
      page.replace_html "post_service_group_list", :partial => "post_service_group_list"
    end
  end

  def get_follower_details
    @followers = current_user.get_followers
    @following = current_user.get_followings
    @friends = current_user.friends
  end

  def get_post_types
    unless params[:type_id].blank?
      @post_service_group = current_user.post_service_groups.find_by_id(params[:type_id])
      if @post_service_group
        type = PostType.find_by_id(@post_service_group.post_type_id)
        get_services(type) if type
      else
        @services = nil
      end
    end
  end

  def get_services(type)
    if type.name == "Photo"
      @services = current_user.active_services.photo_sharing_services
      @service_type = "photo sharing"
    elsif type.name == "Link"
      @services = current_user.active_services.link_sharing_services
      @service_type = "link sharing"
    elsif type.name == "Blog"
      @services = current_user.active_services.blog_sharing_services
      @service_type = "blog sharing"
    elsif type.name == "Status Update"
      @services = current_user.active_services.link_sharing_services
      @service_type = "status update sharing"
    else
      @services = nil
    end
  end

  private
  def load_instances
    @pick_types =  PostType.find(:all)
    @post_service_groups_table = Grid::PostServiceGroupsPreseneter.new(@template)
    @post_service_groups = current_user.post_service_groups.find(:all, :order => @post_service_groups_table.order)
    @post_service_groups = @post_service_groups.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @post_service_groups_table.page || 1, :total_entries => @post_service_groups.size)
  end
end
