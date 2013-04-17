class Grid::Admin::ReportedVideosPresenter < Grid::BasePresenter
  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Stream ID", :order => "stream_id"},
          {:name => "Reporter ID", :order => "reporter_id"},
          {:name => "Description", :order => "description"}
        ],
        :default_order => 'created_at desc',
        :empty => t(:no_video_found),
        :hash_for_path => hash_for_admin_spammed_users_path,
        :search => true,
        :version => 2
      )
    )
  end
end