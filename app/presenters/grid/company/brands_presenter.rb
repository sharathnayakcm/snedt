class Grid::Company::BrandsPresenter < Grid::BasePresenter
  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Brand Name", :order => :name},
          {:name => "Brand Admin", :order => :last_login},
          {:name => "Company Name", :order => :name},
          {:name => "Active Services"},
          {:name => "Pending Services"},
          {:name => "Action"}
        ],
        :default_order => 'created_at ',
        :empty => t(:no_match_found),
        :hash_for_path => hash_for_edit_company_path,
        :search => true,
        :version => 2
      )
    )
  end
end