class BlockedUsersController < ApplicationController

  before_filter :require_user

  def create
    blocked_user = BlockedUser.block(current_user.id, params[:id])
    render :update do |page|
      if blocked_user
        if params[:privacy_page]
          page.replace_html "block_unblock_btn", link_to_remote_with_loader("Unblock this user", :url => blocked_user_path(:id => params[:id], :privacy_page => true), :method => :delete,:html=>{:id => "unblock"})
        else
          page.replace_html "follower_block_#{params[:id]}",link_to_remote("#{t :unblock}", :url => blocked_user_path(:id => params[:id]), :method => :delete, :html => {:class => "smlrBtn"})
          page << "notice('You have blocked this user successfully')"
        end
      else
        page << "notice('Blocking user is not successfull, please try again.')"
      end
    end
  end

  def destroy
    blocked_user = BlockedUser.unblock(current_user.id, params[:id])
    render :update do |page|
      if blocked_user
        if params[:privacy_page]
          page.replace_html "block_unblock_btn", link_to_remote_with_loader("Block this user", :url => blocked_users_path(:id => params[:id], :privacy_page => true), :method => :create)
        elsif params[:tab] == "privacy"
          page << "$j('#blocked_user_#{params[:id]}').remove();notice('You have unblocked this user successfully')"
        else
          page.replace_html "follower_block_#{params[:id]}",link_to_remote("#{t :block}", :url => blocked_user_path(:id => params[:id]), :method => :delete, :html => {:class => "smlrBtn"})
          page << "notice('You have unblocked this user successfully')"
        end
      else
        page << "notice('Blocking user is not successfull, please try again.')"
      end
    end
  end

  private
  def block_unblock_response(blocked_user)

  end
end
