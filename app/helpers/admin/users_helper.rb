module Admin::UsersHelper
  def toggle_status(user)
    remote_function :url => toggle_active_admin_users_path(current_user, :id => user.id), :method => :get
  end
end
