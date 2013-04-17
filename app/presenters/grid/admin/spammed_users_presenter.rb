class Grid::Admin::SpammedUsersPresenter < Grid::BasePresenter
  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Full Name", :order => "users.full_name"},
          {:name => "User Name", :order => "users.user_name"},
          {:name => "Email", :order => "users.email"},
          {:name => "Last Login", :order => "users.last_login"},
          {:name => "Services"},
          {:name => "Status", :order => "users.active"},
          {:name => "Spammed By"},
          {:name => "Action"}
        ],
        :default_order => 'created_at desc',
        :empty => t(:no_match_found),
        :hash_for_path => hash_for_admin_spammed_users_path,
        :search => true,
        :version => 2
      )
    )
  end
end