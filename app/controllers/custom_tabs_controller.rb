class CustomTabsController < ApplicationController

  before_filter :require_user

#  def show
#    @user_tab = UserTab.find_by_id(params[:id])
#    # Only one type of user without any service selected
#    if @user_tab.is_fb != true and @user_tab.is_twitter != true and @user_tab.is_flickr != true
#      one_user_type_selection(@user_tab, current_user)
#      two_user_type_selection(@user_tab,current_user)
#      #      three_user_type_selection(@user_tab)
#      #      all_user_type_selection(@user_tab)
#    else
#      redirect_to root_url
#    end
#  end

  def new
    @custom_tab = current_user.custom_tabs.new
    @followers = current_user.get_followers
    @followings = current_user.get_followings
    @friends = current_user.friends
    @header = "Create Custom Tab"
    render :layout => "redbox"
  end

  def create
    @custom_tab = current_user.custom_tabs.new
    @custom_tab.name = params[:tab_name]
    @custom_tab.service_ids = params[:service_ids].to_a.join(",")
    @custom_tab.user_type_ids = params[:user_type_ids].to_a.join(",")
    @custom_tab.user_service_ids = params[:service_ids].to_a.join(",")
    @custom_tab.filter_user_ids = params[:filter_user_ids].to_a.join(",")
    if @custom_tab.save
      render :update do |page|
        flash[:notice] = "Tab created successfully"
        page.redirect_to root_url
      end
    else
      render :update do |page|
        page.replace_html "errors",  @custom_tab.errors.full_messages.join("<br /><br /> * ").collect {|x|  " * " + x  }
      end
    end
    
  end

  def edit
    @custom_tab = CustomTab.find(params[:id])
    @users = User.find(:all, :conditions => ["id in (?)", @custom_tab.filter_user_ids.to_s.split(',')])
    @followers = current_user.get_followers
    @followings = current_user.get_followings
    @friends = current_user.friends
    @header = "Edit Custom Tab"
    render :layout => "redbox"
  end
  
  def update_custom_tabs
    @custom_tab = CustomTab.find(params[:id])
    @header = "Edit Custom Tab"
    @custom_tab.name = params[:tab_name]
    service_ids = params[:service_ids].to_a.join(",")
    user_type_ids = params[:user_type_ids].to_a.join(",")
    user_service_ids = params[:service_ids].to_a.join(",")
    filter_user_ids = params[:filter_user_ids].to_a.join(",")
    if @custom_tab.update_attributes(:user_type_ids => user_type_ids, :service_ids => service_ids,:user_service_ids => user_service_ids, :name =>params[:tab_name], :filter_user_ids => filter_user_ids)
      render :update do |page|
        flash[:notice] = "Tab updated successfully"
        page.redirect_to :controller => :home, :action => :display_custom_streams, :id => params[:id]
      end
    else
      render :update do |page|
        page.replace_html "errors", @custom_tab.errors.full_messages.join("<br />")
      end
    end
  end
  def get_names
    unless params[:input_first_name].blank?
      @names = CustomTab.find_names(params[:input_first_name],current_user)
    end
    render :layout => false
  end

  def streams
    user_tab = current_user.user_tabs.find_by_id(params[:id], :include => [:tab])
    @no_post_panel = true
    @stream_header = user_tab.tab.tab_path
    load_instances(false)
    @streams = current_user.send("#{@stream_header}_streams")
    unless @streams.blank?
      @streams = @streams.paginate(:per_page => 25, :page => params[:page] || 1)
    end
    @display_in_tabs = true
    render :index
  end

end
