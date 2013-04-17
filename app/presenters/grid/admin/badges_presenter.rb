class Grid::Admin::BadgesPresenter < Grid::BasePresenter

  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Badges", :order => :name},
          {:name => "Image"},
          {:name => "Action"}
        ],
        :default_order => 'created_at desc',
        :empty => t(:no_match_found),
        :hash_for_path => hash_for_admin_badges_path,
        :search => true,
        :version => 2
      )
    )
  end
end
