class Grid::Admin::NotificationsPresenter < Grid::BasePresenter

  def initialize(template, options = {}, from=nil)
    initialize_template template
    if from.blank?
      column = [
          {:name => "Title", :order => :name},
          {:name => "Code", :order => :code},
          {:name => "Subject", :order => :subject},
          {:name => "CC", :order => :cc},
          {:name => "BCC", :order => :bcc},
          {:name => "Displayable", :order => :is_displayable},
          {:name => "Active", :order => :active},
          {:name => "Action"}
        ]
        hash_path = hash_for_admin_notifications_path
    else
      column = [
          {:name => "Title", :order => :name},
          {:name => "Code", :order => :code},
          {:name => "Subject", :order => :subject},
          {:name => "CC", :order => :cc},
          {:name => "BCC", :order => :bcc},
          {:name => "Days After Delivery", :order => :delivery_day},
          {:name => "Active", :order => :active},
          {:name => "Action"}
        ]
        hash_path = hash_for_admin_user_engagements_path
    end
    super(
      template,
      options.reverse_merge(
        :columns => column,
        :default_order => 'created_at desc',
        :empty => t(:no_notifications_found),
        :hash_for_path => hash_path,
        :search => true,
        :version => 2
      )
    )
  end
end
