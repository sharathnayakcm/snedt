class Grid::Admin::RssPresenter < Grid::BasePresenter

  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "RSS Link", :order => :url},
          {:name => "Status", :order => :status},
          {:name => "Action"}
        ],
        :default_order => 'created_at desc',
        :empty => t(:no_rss_links_found),
        :hash_for_path => hash_for_admin_admin_rss_links_path,
        :search => true,
        :version => 2
      )
    )
  end
end