class Grid::Admin::SubscriptionsPresenter < Grid::BasePresenter
  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "ID", :order => "id"},
          {:name => "Name", :order => "name"},
          {:name => "Description", :order => "description"},
          {:name => "Membership Type", :order => "membership_type"},
          {:name => "Amount", :order => "amount"},
          {:name => "Upload Limit", :order => "upload_limit"},
          {:name => "Trial Period Allowed", :order => "is_trial_period_allowed"},
          {:name => "Trial Period(days)", :order => "trial_period"},
          {:name => "Active", :order => "active"},
          {:name => "Action"}
        ],
        :default_order => 'created_at desc',
        :empty => t(:no_video_found),
        :hash_for_path => hash_for_admin_subscriptions_path,
        :search => true,
        :version => 2
      )
    )
  end
end