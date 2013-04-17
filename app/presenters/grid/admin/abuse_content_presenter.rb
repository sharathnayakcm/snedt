class Grid::Admin::AbuseContentPresenter < Grid::BasePresenter

  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Stream", :order => :stream_id},
          {:name => "Reason", :order => :reason},
          {:name => "Reported By"},
          {:name => "Reporter Comments", :order => :user_comments},
          {:name => "Stream Owner"},
          {:name => "Action"}
        ],
        :default_order => 'created_at desc',
        :empty => t(:no_abuse_contents_found),
        :hash_for_path => hash_for_admin_abuse_contents_path,
        :search => true,
        :version => 2
      )
    )
  end
end