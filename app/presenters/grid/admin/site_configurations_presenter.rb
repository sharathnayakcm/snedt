class Grid::Admin::SiteConfigurationsPresenter < Grid::BasePresenter
def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Configuration Name", :order => :name},
          {:name => "Code", :order => :code},
          {:name => "Value", :order => :value},
          {:name => "Action"}
        ],
        :default_order => 'created_at desc',
        :empty => t(:no_match_found),
        :hash_for_path => hash_for_admin_site_configurations_path,
        :search => true,
        :version => 2
      )
    )
  end
end
