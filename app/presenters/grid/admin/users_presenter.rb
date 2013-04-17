class Grid::Admin::UsersPresenter < Grid::BasePresenter
  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Full Name", :order => :full_name},
          {:name => "User Name", :order => :user_name},
          {:name => "Email", :order => :email},
          {:name => "Membership"},
          {:name => "Last Login", :order => :last_login},
          {:name => "Services"},
          {:name => "Pending Services"},
          {:name => "Member Since", :order => :created_at},
          {:name => "Delete in", :order => :deleted_at},
          {:name => "Status", :order => :active},
          {:name => "Action"}
        ],
        :default_order => 'last_login desc',
        :empty => t(:no_match_found),
        :hash_for_path => hash_for_admin_users_path,
        :search => true,
        :version => 2
      )
    )
  end
end