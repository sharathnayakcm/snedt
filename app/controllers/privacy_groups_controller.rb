class PrivacyGroupsController < ApplicationController

  def index
    get_follower_details
    @privacy_groups_table = Grid::PrivacyGroupsPreseneter.new(@template)
    @privacy_groups = current_user.privacy_groups.find(:all, :order => @privacy_groups_table.order)
    @privacy_groups = @privacy_groups.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @privacy_groups_table.page || 1, :total_entries => @privacy_groups.size)
    render :layout => false if request.xhr?
  end

  def new
    get_follower_details
  end

  def create
    begin
      group_ids = params[:followingsid].to_a + params[:followersid].to_a + params[:friendsid].to_a
      if group_ids.blank? && params[:members].blank? && params[:privacy_user_ids].blank?
        render :update do |page|
          page << "notice('Please pick members for the privacy group')"
          page << "$j('#spinner_tag').hide();"
        end
      else
        current_user.privacy_groups.create(:name => params[:pg_name], :group_ids => params[:members].to_a * ",", :group_user_ids => group_ids.to_a * ",", :service_ids => params[:serviceid].to_a * ",", :user_ids => params[:privacy_user_ids].to_a * ",")
        if params[:tab] == "privacy"
          @privacy_groups = current_user.privacy_groups
          @user = current_user
          @privacy_setting = current_user.read_or_create_privacy_setting
          @stream_actions = current_user.read_or_create_stream_actions
          render :update do |page|
            page.replace_html "personalEditPG", :partial => "users/edit_privacy_groups"
            page.replace_html "servicePrivacies", :partial => "users/service_privacies"
            page.replace_html "whoSeesFullname", :partial => "users/who_sees_fullname"
            page << "$j('#added_users').html('');$j('#personalPrivacySetting').hide();"
            page << "$('pgForm').reset();"
            page << "$j('#spinner_tag').hide();"
            page << "notice('Privacy group created successfully')"
          end
        else
          get_follower_details
          @privacy_groups_table = Grid::PrivacyGroupsPreseneter.new(@template)
          @privacy_groups = current_user.privacy_groups(:order => @privacy_groups_table.order)
          @privacy_groups = @privacy_groups.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @privacy_groups_table.page || 1, :total_entries => @privacy_groups.size)
          render :update do |page|
            page.replace_html "form_content", :partial => "privacy_groups/new"
            page.replace_html "privacy_group_list", :partial => "privacy_groups/privacy_group_list"
            page << "$j('#spinner_tag').hide();"
            page << "$j('#pg_count').html(#{current_user.privacy_groups.count});"
            page << "notice('Privacy group created successfully')"
          end
        end
      end
    rescue Exception => e
      render :update do |page|
        page << "notice('Privacy group not created. Please try agian')"
        page << "$j('#spinner_tag').hide();"
      end
    end
  end

  def update_form
    @privacy_group = PrivacyGroup.find(params[:id])
    @privacy_groups = current_user.privacy_groups
    group_ids = params[:followingsid].to_a + params[:followersid].to_a + params[:friendsid].to_a
    @group = current_user.privacy_groups.find_by_id(params[:grp_id])
    @privacy_group.update_attributes(:name => params[:pg_name], :group_ids => params[:members].to_a * ",", :group_user_ids => group_ids.to_a * ",", :service_ids => params[:serviceid].to_a * ",", :user_ids => params[:user_ids].to_a * ",")
    @privacy_group.reload
    @privacy_groups_table = Grid::PrivacyGroupsPreseneter.new(@template)
    @privacy_groups = current_user.privacy_groups(:order => @privacy_groups_table.order)
    @privacy_groups = @privacy_groups.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @privacy_groups_table.page || 1, :total_entries => @privacy_groups.size)
    get_follower_details
    render :update do |page|
      page << "$j('#spinner_tag').hide();"
      page.replace_html "form_content", :partial => "privacy_groups/new"
      page.replace_html "privacy_group_list", :partial => "privacy_groups/privacy_group_list"
      page << "notice('Privacy group updated successfully')"
    end
  end

  def edit
    @privacy_groups = current_user.privacy_groups
    @privacy_group = PrivacyGroup.find(params[:id])
    @saved_users = User.find(:all,:select => "id, user_name, full_name",  :conditions => "id in (#{@privacy_group.user_ids})") unless @privacy_group.user_ids.blank?
    get_follower_details
    render :layout => false
  end

  def show
    @is_edit = true
    @privacy_groups = current_user.privacy_groups
    @privacy_group = PrivacyGroup.find(params[:id])
    @users = User.find(:all, :conditions => "id in (#{@privacy_group.user_ids})") unless @privacy_group.user_ids.blank?
    get_follower_details
    render :update do |page|
      page << "$('personalEditPGDetail').style.display = 'block'"
      page.replace_html "personalEditPGDetail", :partial => "users/edit_privacy_group"
    end
  end

  def update_group
    if params[:edit_privacy_user_ids].blank?
      render :update do |page|
        page << "notice('Please pick members for the privacy group')"
        page << "$j('#spinner_tag').hide();"
      end
    else
      group = current_user.privacy_groups.find_by_id(params[:pg_id])
      if group
        group.update_attributes({:name => params[:pg_name_edit], :user_ids => params[:edit_privacy_user_ids].to_a * ","})
        @privacy_groups = current_user.privacy_groups
        render :update do |page|
          page << "$j('#editPGName_#{group.id}').html('#{params[:pg_name_edit]}')"
          page << "$('personalEditPGDetail').style.display = 'none'"
          page.replace_html "personalEditPGDetail", ""
          page << "notice('Privacy group updated successfully')"
        end
      else
        render :update do |page|
          page << "notice('Privacy group not updated. Please try agian')"
        end
      end
    end
  end

  def edit_form
    if params[:id] == "0"
      render :update do |page|
        page.replace_html "edit_form", ""
      end
    else
      get_follower_details
      @group = current_user.privacy_groups.find_by_id(params[:id])
      if @group
        #        render :update do |page|
        #          page.replace_html "edit_form", :partial => "edit_form"
        #        end
      else
        #        render :update do |page|
        #          page.replace_html "edit_form", ""
        #        end
      end
    end
  end

  def delete
    privacy_group = current_user.privacy_groups.find_by_id(params[:id])
    privacy_group.destroy
    @privacy_groups = current_user.privacy_groups.reload
    @user = current_user
    @privacy_setting = current_user.read_or_create_privacy_setting
    @stream_actions = current_user.read_or_create_stream_actions
    render :update do |page|
      page << "$('personalEditPGDetail').style.display = 'none'"
      page.replace_html "servicePrivacies", :partial => "users/service_privacies"
      page.replace_html "whoSeesFullname", :partial => "users/who_sees_fullname"
      page.replace_html "personalEditPG", :partial => "users/edit_privacy_groups"
      page << "notice('Privacy group deleted successfully')"
      page << "RedBox.close()"
    end
  end

  def delete_confirm
    @group_id = params[:id]
    @header = "Remove Privacy Group"
    render :layout => 'redbox'
  end

  def get_follower_details
    @followers = current_user.get_followers
    @followings = current_user.get_followings
    @friends = current_user.friends
    @privacy_groups = current_user.privacy_groups
  end

  def get_names
    unless params[:input_first_name].blank?
      @names = CustomTab.find_user_names(params[:input_first_name],current_user)
    end
    render :layout => false
  end

  def get_names_for_privacy_tab
    @is_edit = !params[:is_edit].blank?
    unless params[:input_first_name].blank?
      @names = CustomTab.find_user_names(params[:input_first_name],current_user)
    end
    render :layout => false
  end

  def list_added_users
    user_ids = (params[:user_ids].split(',') + params[:user_id].to_a).join(',')
    @users = User.find(:all, :conditions => ["id in (?)", user_ids.split(',')])
    render :update do |page|
      unless params[:edit] == "true"
        page << "$j('#searched_user_#{params[:user_id]}').hide();"
        page << "$j('#privacy_user_ids').val('#{user_ids}');"
        page.replace_html "added_users", :partial => "privacy_groups/added_users"
      else
        @is_edit = true
        page << "$j('#searched_user_#{params[:user_id]}').hide();"
        page << "$j('#edit_privacy_user_ids').val('#{user_ids}');"
        page.replace_html "added_users_edit", :partial => "privacy_groups/added_users"
      end
    end
  end

  def remove_added_users
    user_ids = (params[:user_ids].split(',') - params[:user_id].to_a).join(',')
    @users = User.find(:all, :conditions => ["id in (?)", user_ids.split(',')])
    render :update do |page|
      unless params[:edit] == "true"
        page << "$j('#searched_user_#{params[:user_id]}').show();"
        page << "$j('#privacy_user_ids').val('#{user_ids}');"
        page.replace_html "added_users", :partial => "privacy_groups/added_users"
      else
        @is_edit = true
        page << "$j('#searched_user_#{params[:user_id]}').show();"
        page << "$j('#edit_privacy_user_ids').val('#{user_ids}');"
        page.replace_html "added_users_edit", :partial => "privacy_groups/added_users"
      end
    end
  end

end
