ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end
  map.home 'home', :controller => 'home', :action => 'index'
  map.social_inbox 'social_inbox', :controller => 'home', :action => 'index'
  map.my_streams 'my_streams', :controller => 'home', :action => 'index'
  map.welcome 'welcome', :controller => 'home', :action => 'welcome'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.vimeo 'vimeo', :controller => 'user_sessions', :action => 'vimeo_callback'
  map.feautres 'features', :controller => "home", :action => "features"
  map.about 'about', :controller => "home", :action => "about"
  map.terms_of_use 'terms_of_use', :controller => "home", :action => "terms_of_use"
  map.privacy_policy 'privacy_policy', :controller => "home", :action => "privacy_policy"
  map.youtube 'youtube', :controller => 'user_sessions', :action => 'youtube_callback'
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.stream 'stream/:id', :controller => 'profiles', :action => 'show_stream'
  map.edit 'users/:id/edit', :controller => 'users', :action => 'edit'
  map.checkuser '/user_validation', :controller => 'users', :action => 'user_validation', :method => :get
  map.checkcompany_name '/company_name_validation', :controller => 'companies', :action => 'company_name_validation', :method => :get
  map.rss 'rss/:user_name/:custom_id', :controller => 'custom_streams', :action => 'rss'
  #map.mark_as_read '/mark_as_read', :controller => 'streams', :action => 'mark_as_read', :method => :get
  map.profile "profile",:controller => "users", :action => "edit"
  map.profiles "profiles/more_streams",:controller => "profiles", :action => "more_streams"
  map.profiles "profiles/followers/:id",:controller => "profiles", :action => "followers"
  map.profiles "profiles/followings/:id",:controller => "profiles", :action => "followings"
  map.profiles "profiles/friends/:id",:controller => "profiles", :action => "friends"
  map.apply_skin "profiles/apply_skin",:controller => "profiles", :action => "apply_skin"
  map.profiles "profiles/:id",:controller => "profiles", :action => "index"
  map.forgot_password "forgot_password", :controller =>"password_resets", :action => :new
  map.resend_activation "resend_activation", :controller => 'activations', :action => 'edit'
  map.resources :activations, :collection => {:payment => :any, :free_account => :any, :resend => :any}
  map.activate '/activate/:activation_code', :controller => 'activations', :action => 'create'
  map.zendesk 'zendesk', :controller => 'user_sessions', :action => 'zendesk_login'
  map.zendesk_logout '/zendesk/logout', :controller => 'user_sessions', :action => 'zendesk_logout'
  map.help 'help', :controller => "home", :action => "help"
  map.resource :user_sessions, :collection => {:sign_in => :get, :add_new_tab => :get, :callback => :get, :logout => :any},:member => {:post_twitter_message => :post}
  map.plans_and_pricing 'plans_and_pricing',:controller => "user_sessions",:action => "plans_and_pricing"
  map.root  :controller => 'user_sessions', :action => 'new'# optional, this just sets the root route
  map.features_starter 'features_starter',:controller => 'home',:action => 'features'
  map.features_premium 'features_premium',:controller => 'home',:action => 'features'
  map.features_business 'features_business',:controller => 'home',:action => 'features'
  map.features_comparison 'features_comparison',:controller => 'home',:action => 'features'
  map.tutorial 'tutorial/:name', :controller => 'home', :action => 'tutorial'
  map.brands 'brands/:id', :controller => 'companies', :action => 'show'
  map.brands 'brands/:company_id/:id', :controller => 'companies/brands', :action => 'show'
  map.brand_profile 'profile/:id', :controller => 'companies/brands', :action => 'profile'
  #map.connect "/:id", {:controller => "user_sessions", :action => "sign_in"}

  map.resources :password_resets
  map.resources :privacy_groups, :collection => {:update_form => :get, :list_added_users => :any, :remove_added_users => :any, :update_group => :any}
  map.resources :post_service_groups, :collection => {:get_post_types => :get, :destroy_post_service_group => :get, :update_form =>:get}

  map.resource :users , :collection => {:done => :any, :user_validation => :any, :show_time_zone => :any, :update_notifications => :any, :upload => :any, :delete_avatar => :any,:update_password=>:any, :payment_options => :any, :payment_success => :any, :payment_failure => :any, :downgrade_to_free => :any, :downgrade_confirm => :any, :upgrade_to_premium => :any, :back_from_cashu => :any, :more_users => :any}

  map.resources :users, :collection => {:terms => :any, :search_user => :get, :search_user_from_header => :get,:search_topic=>:get,:search_stream_topic=>:get} do |user|
    user.resources :privacies, :controller => "Users::Privacies", :member => {:edit_privacy => :any, :update => :any, :update_stream_actions => :any}
    user.resources :services, :controller => "Users::Services", :collection => {:add_new => :any, :create_service => :any, :delete_user_service => :get, :back_from_cashu=> :any, :save_facebook_page => :any, :configure_fb_page => :get}
    user.resources :friends, :controller => "Users::Friends", :collection => { :add_friends => :get, :add_friends_from_contacts => :get, :search_friends => :get, :find_friends => :get , :invite_friends =>:get, :unfollow => :get, :follow => :get, :invite_friends_to_brand => :get}
    user.resources :brands, :controller => "Users::Brands", :collection => {:add_brand => :get}
  end

  map.resources :admin, :controller => 'Admin' do |admin|
    admin.resources :users, :controller => "Admin::Users", :collection => { :reset_password => :get, :toggle_active => :get }
    admin.resources :spammed_users, :collection => {:process_spam => :any}, :controller => "Admin::SpammedUsers"
    admin.resources :static_pages, :controller => "Admin::StaticPages"
    admin.resources :uploads, :controller => "Admin::Uploads", :collection => {:update_setting => :any}
    admin.resources :reported_videos, :controller => "Admin::ReportedVideos"
    admin.resources :subscriptions, :controller => "Admin::Subscriptions"
    admin.resources :services, :controller => "Admin::Services"
    admin.resources :dashboard, :controller => "Admin::Dashboard", :collection => {:load_data => :any, :export_csv => :any}
    admin.resources :notifications, :controller => "Admin::Notifications"
    admin.resources :admin_rss_links, :controller => "Admin::AdminRssLinks", :collection => {:add_link => :any,:delete_link => :get,:rename_link => :get,:search_link => :get, :search_results => :get, :save_link => :get,:show_detail => :get, :more_streams => :get, :close_link_window => :get, :manage_rss => :any, :change_status => :any}
    admin.resources :abuse_contents, :controller => "Admin::AbuseContents"
    admin.resources :companies, :controller => "Admin::Companies", :collection => { :reset_password => :get, :toggle_active => :get }
    admin.resources :site_configurations, :controller => "Admin::SiteConfigurations"
    admin.resources :user_engagements, :controller => "Admin::UserEngagements"
    admin.resources :topics, :controller => "Admin::Topics"
    admin.resources :badges, :controller => "Admin::Badges"
    admin.resources :points, :controller => "Admin::Points"
  end

  map.resources :streams, :collection => {:retweet => :get, :get_stream_from_db => :get, :upgrade_member_video => :get, :delete_stream => :any, :flag_video => :any, :flag_video_confirm => :any, :shorten_link => :get, :mark_as_read => :any,:show_full_image => :get, :mark_all_read => :get, :mark_all_unread => :get, :save_stream_settings => :get, :report_abuse => :any, :report_abuse_admin => :get, :share_stream => :post, :get_topics => :get},:member =>{ :add_thankyou => :get, :toggle_favourite => :get,:toggle_read => :get, :update_stream_topic => :get, :update_rating => :any, :mark_as_favourite => :any, :add_view_count => :any, :facebook_comments => :any, :twitter_comments => :any}, :shallow=>true do |stream|
    stream.resources :comments, :controller => "Streams::Comments"
  end

  map.resources :posts, :collection => {:post_photo => :get,:cancel_upload => :get, :upload => :get, :upload_video => :get}
  map.resources :rss, :collection => {:add_link => :get,:delete_link => :get,:rename_link => :get,:search_link => :get, :search_results => :get, :save_link => :get,:show_detail => :get, :more_streams => :get, :close_link_window => :get}

  map.resource :home, :collection => {:add_new_tab => :get, :display_custom_tabs => :get, :get_streams => :get,:get_topic_count => :get, :save_search => :get, :welcome_premium => :get, :activation_reminder => :get}, :member => {:delete_marked_tab => :get, :create_custom_tab => :get, :add_tag => :get, :rate_stream => :get, :custom_tabs => :get, :close_link_window => :get, :remove_search => :get}, :controller => "Home"
  map.resources :custom_tabs, :member => {:update_custom_tabs => :get, :get_names => :get, :streams => :get}
  map.resources :side_bar, :collection => {:followers_list => :get, :followings_list => :get, :friends_list => :get, :get_unfollow => :get, :toggle_follow => :get, :toggle_block => :get, :toggle_block_friends => :get}
  #  map.resources :twits, :collection => {:callback => :get, :update_status => :get, :direct_messages => :get}
  map.resources :followings, :collection => { :update_privacy_group => :any, :follow => :any, :unfollow => :any, :streams => :any, :more_streams => :get }
  map.resources :followers, :collection => { :update_privacy_group => :any, :follow => :any, :unfollow => :any, :streams => :any, :more_streams => :get }
  map.resources :friends, :collection => { :update_privacy_group => :any, :follow => :any, :unfollow => :any, :streams => :any , :filter_streams => :any, :more_streams => :get}
  map.resources :tabs
  map.resources :topics, :collection => {:add_user_topic => :post,:add_stream_topic_and_tag => :get,:add_topic_tag => :get,:sign_up_topics => :get},:member => {:show_followers =>:get} do |topic|
    topic.resources :topic_followers
  end
  map.resources :activities
  map.resources :user_tabs
  map.resources :custom_streams, :collection => {:new => :get, :edit => :get, :delete => :post, :update => :post, :rss => :get}
  map.resources :tags, :collection => {:create => :post, :delete => :post}

  map.resources :custom_streams, :collection => {:new => :get, :edit => :get, :delete => :post, :update => :post}
  map.resources :blocked_users
  map.resources :profiles, :collection => {:follow => :any, :unfollow => :any, :report_as_spammer => :any, :undo_spammer => :any, :more_streams => :any, :apply_active_skin => :any,:followers =>:get,:followings => :get,:friends => :get}
  map.resources :skins, :collection => {:update_active_skin => :any, :upload_image => :any, :apply_active_skin => :any, :delete_image => :any, :delete_skin => :any}
  map.resources :brand_skins, :collection => {:update_active_skin => :any, :upload_image => :any, :apply_active_skin => :any, :delete_image => :any, :delete_skin => :any}
  map.resources :companies, :collection => {:company_name_validation => :any, :downgrade => :any, :downgrade_membership => :any, :down_or_upgrade => :any, :down_or_upgrade_membership => :any, :payment_success => :any, :payment_failure => :any} do |company|
    company.resources :brands, :controller => "Companies::Brands", :collection => {:add_services => :get, :create_service => :post, :privacy => :get, :add_privacy => :post, :update_privacy => :put, :apply_skin => :get}, :member => { :services => :get, :profile => :get, :add => :any}
    company.resources :services, :controller => "Companies::Services", :collection => {:add_new => :any, :create_service => :any, :delete_user_service => :get}
    company.resources :brand_user_groups, :controller => "Companies::BrandUserGroups", :collection => { :confirm_reqeust => :any }
    company.resources :followers, :controller => "Companies::Followers", :collection => { :follow => :get, :unfollow => :get }
    company.resources :dashboard, :controller => "Companies::Dashboard", :collection => { :load_data => :any, :brand_select => :any, :export_csv => :any}
    company.resources :invitations, :controller => "Companies::Invitations", :collection => { :invite_friends => :get}
  end

  map.resources :brands, :controller => "Companies::Brands", :member => { :profile => :get, :apply_skin => :get}


  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
