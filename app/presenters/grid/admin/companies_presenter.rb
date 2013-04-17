class Grid::Admin::CompaniesPresenter < Grid::BasePresenter
  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Company Name", :order => :name},
          {:name => "Admin", :order => :user_name},
          {:name => "URL", :order => :url},
          {:name => "Last Login", :order => :last_login},
          {:name => "Services"},
          {:name => "Pending Services"},
          {:name => "Member Since", :order => :created_at},
          {:name => "Delete in", :order => :deleted_at},
          {:name => "Status", :order => :active},
          {:name => "Action"}
        ],
        :default_order => 'created_at ',
        :empty => t(:no_match_found),
        :hash_for_path => hash_for_admin_companies_path,
        :search => true,
        :version => 2
      )
    )
  end
end