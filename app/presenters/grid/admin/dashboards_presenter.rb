class Grid::Admin::DashboardsPresenter < Grid::BasePresenter

  def initialize(template, options = {}, type="")
    initialize_template template
    columns = []
    columns = case type
    when "individual" then
      [   {:name => "Date"}] + Membership.individual.collect{|membership| { :name => "#{membership.name}"}  }
    when "company" then
      [   {:name => "Date"}
      ] + Membership.business.collect{|membership| { :name => "#{membership.name}"}  }
    when "service" then
      [   {:name => "Date"},
        {:name => "Flickr"},
        {:name => "Delicious"},
        {:name => "RSS Feed"},
        {:name => "Vimeo"},
        {:name => "Youtube"},
        {:name => "Stumbleupon"},
        {:name => "Facebook"},
        {:name => "Tumblr"},
        {:name => "Facebook Page"}
      ]
    when "individual_upgrade" then
      [   {:name => "Date"},
        {:name => "Starter to Premium"}
      ]
    when "company_upgrade" then
      [   {:name => "Date"},
        {:name => "Gold-Silver"},
        {:name => "Silver-Bronze"},
        {:name => "Bronze-Gold"},
        {:name => "Gold-Bronze"},
        {:name => "Silver-Gold"},
        {:name => "Bronze-Silver"},
        {:name => "Platinum-Gold"},
        {:name => "Platinum-Silver"},
        {:name => "Platinum-Bronze"},
        {:name => "Gold-Platinum"},
        {:name => "Silver-Platinum"},
        {:name => "Bronze-Platinum"},
      ]
    when "revenue" then
      [   {:name => "Date"}] +
        Membership.paid_plans.collect{|membership| { :name => "#{membership.name}"}  }
      

    when "users" then
      Membership.all.collect{|membership| { :name => "#{membership.name}"}  } << {:name => "Total"}

    when "service_usage" then
      Service.all.collect{|service| { :name => "#{service.name}"}  } << {:name => "edintity"} << {:name => "Total"}
    when "post_type" then
      PostType.all.collect{|post_type| { :name => "#{post_type.name}"}  } << {:name => "Total"}
    end


    super(
      template,
      options.reverse_merge(
        :columns => columns,
        :default_order => 'created_at desc',
        :empty => t(:no_data),
        :hash_for_path => hash_for_admin_dashboards_path,
        :search => true,
        :version => 2
      )
    )
  end
end

