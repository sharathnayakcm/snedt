class UserTabsController < ApplicationController

  def index

  end

  def new

  end

  def create
    @tab = UserSession.find_tab_from_db(params[:tab])
    @user_tab = current_user.user_tabs.find_all_by_tab_id(@tab.id)
    unless params[:tab].to_i == 5 # for custom tab  #TODO instead 5 constants need to be initialized in tab model
      UserTab.create(:user_id => current_user.id, :tab_id => @tab.id)
      tab_path = @tab.tab_path == "rss_reader" ? "/home/#{@tab.tab_path}" : "/#{@tab.tab_path}/streams"
      render :update do |page|
        page.redirect_to(tab_path)
      end
    else
      @custom_tab = true
    end
    load_user_tabs
  end


  def destroy
    @user_tab = current_user.user_tabs.find_by_id(params[:id])
    unless @user_tab.blank?
      @user_tab.destroy
    else
      @custom_tab = current_user.custom_tabs.find_by_id(params[:id])
      @custom_tab.destroy unless @custom_tab.blank?
    end
    @user_tabs = current_user.active_tabs
    @user_unused_tabs = current_user.unused_tabs
    render :update do |page|
      page << "notice('#{t :tab_deleted}')"
      page.replace_html "user_tabs_new", :partial => "shared/user_tabs"
      page.redirect_to(root_path)
    end
  end

  private

  def load_user_tabs
    @user_tabs = current_user.active_tabs
    @user_unused_tabs = current_user.unused_tabs
  end
end
