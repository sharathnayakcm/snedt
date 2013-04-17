class Admin::SpammedUsersController < ApplicationController
  before_filter :require_user
  before_filter :admin_required
  def index
    load_spammed_users
    render :layout => false if request.xhr?
  end

  def process_spam
    spammed_user = SpammedUser.find_by_id(params[:id])
    spammed_user.process_spam_request(params)

    render :update do |page|
      page.replace_html "action_#{spammed_user.id}", params[:scope].blank? ? "<b>Marked As Spammer</b>" : "<b>#{params[:scope].capitalize}ed</b>"
    end
  end

  

  private


  def load_spammed_users
    @spammed_users_table = Grid::Admin::SpammedUsersPresenter.new(@template)
    @spammed_users = SpammedUser.all(:order => @spammed_users_table.order, :conditions => ["revealed_at is null"])
    @spammed_users = @spammed_users.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @spammed_users_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @spammed_users.size)
  end

end
