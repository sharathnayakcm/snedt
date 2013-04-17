class Grid::Admin::ServicesPresenter < Grid::BasePresenter

  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Service Name", :order => :name},
          {:name => "Service URL", :order => :url},
          {:name => "Callback URL", :order => :callback_url},
          {:name => "Description", :order => :description},
          {:name => "Category", :order => "service_categories.name"},
          {:name => "API Token", :order => :api_token},
          {:name => "API Key", :order => :api_key},
          {:name => "Action"}
        ],
        :default_order => 'created_at desc',
        :empty => t(:no_match_found),
        :hash_for_path => hash_for_admin_services_path,
        :search => true,
        :version => 2
      )
    )
  end
end
