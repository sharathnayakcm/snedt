class Admin::DashboardController < ApplicationController
  require 'fastercsv'
  before_filter :require_user
  before_filter :admin_required
  include ActionView::Helpers::NumberHelper
  def index
    @dates = set_dates
    @individual_table = Grid::Admin::DashboardsPresenter.new(@template, {}, "individual")
    @company_table = Grid::Admin::DashboardsPresenter.new(@template, {}, "company")
    @service_table = Grid::Admin::DashboardsPresenter.new(@template, {}, "service")
    @individual_upgrade_table = Grid::Admin::DashboardsPresenter.new(@template, {}, "individual_upgrade")
    @company_upgrade_table = Grid::Admin::DashboardsPresenter.new(@template, {}, "company_upgrade")
    @revenue_table = Grid::Admin::DashboardsPresenter.new(@template, {}, "revenue")
    @user_table = Grid::Admin::DashboardsPresenter.new(@template, {}, "users")
    @service_usage = Grid::Admin::DashboardsPresenter.new(@template, {}, "service_usage")
    @service_usage_by_post_type = Grid::Admin::DashboardsPresenter.new(@template, {}, "post_type")
    get_memberships
    get_individual_user_signup_data(true)
    get_company_user_signup_data(true)
    get_user_usage_data(true)
    get_company_usage_data(true)
    get_user_sevice_data(true)
    get_company_sevice_data(true)
    get_individual_upgrade_stats(true)
    get_company_upgrade_stats(true)
    get_revenue_report(true)
  end

  def load_data
    @dates = set_dates
    case params[:type]
    when "individual_user_signup" then
      get_individual_user_signup_data
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/individual_signup_stats"
      end
    when "company_user_signup" then
      get_company_user_signup_data
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/user_type_signup_stats"
      end
    when "country_user_signup" then
      get_country_user_signup_data
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/countrywise_signup_stats"
      end
    when "company_user_usage" then
      get_company_usage_data
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/company_usage_stats"
      end
    when "individual_user_usage" then
      get_user_usage_data
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/user_usage_stats"
      end
    when "post_method_usage" then
      get_post_method_usage_data
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/post_method_usage_stats"
      end
    when "individual_user_service" then
      get_user_sevice_data
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/user_service_stats"
      end
    when "company_user_service" then
      get_company_sevice_data
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/company_service_stats"
      end
    when "individual_upgrade" then
      get_individual_upgrade_stats
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/upgrade_stats"
      end
    when "company_upgrade" then
      get_company_upgrade_stats
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/company_upgrade_stats"
      end
    when "revenue_report" then
      get_revenue_report
      render :update do |page|
        page.replace_html "chart_div",:partial => "admin/dashboard/revenue_report"
      end
    end
  end

  def get_individual_user_signup_data(table_view = false)
    @individual_data = User.get_individual_user_signup_stats(@dates[0], @dates[1], table_view)
    if table_view
      @header = ["Date"] + @individual_memberships
      @data_array = []
      @individual_data.each do |individual|
        data = [individual.date]
        @individual_memberships.each do |membership|
          data << (individual.membership_name == membership ? individual.user_count : 0)
        end
        @data_array << data
      end
    end
  end

  def get_company_user_signup_data(table_view = false)
    @company_data = User.get_company_signup_stats(@dates[0], @dates[1], table_view)
    if table_view
      @header = ["Date"] + @company_memberships
      @data_array = []
      @company_data.each do |company|
        data = [company.date]
        @company_memberships.each do |membership|
          data << (company.membership_name == membership ? company.company_count : 0)
        end
        @data_array << data
      end
    end
  end

  def get_country_user_signup_data(table_view = false)
    @country_data = User.get_country_signup_stats(@dates[0], @dates[1], table_view)
    if table_view
      countries = @country_data.collect{|user| user.country}.uniq
      @header = ["Date"] + countries
      @data_array = []
      @country_data.each do |user|
        data = [user.date]
        countries.each do |country|
          data << (user.country == country ? user.users_count : 0)
        end
        @data_array << data
      end
    end
  end

  def get_post_method_usage_data(table_view = false)
    @post_method_usage_data = Asset.get_post_method_usage_stats(@dates[0], @dates[1], table_view)
    if table_view
      methods = ["Video", "Photo"]
      @header = ["Date"] + methods
      @data_array = []
      @post_method_usage_data.each do |usage|
        data = [usage.date]
        methods.each do |method|
          data << (method == "Video" ? "#{((usage.video_size.to_i/1024/1024.0)*1000).round.to_f/1000} MB" : "#{((usage.photo_size.to_i/1024/1024.0)*1000).round.to_f/1000} MB")
        end
        @data_array << data
      end
    end
  end

  def get_user_usage_data(table_view = false)
    @user_usage_data = Asset.get_user_usage_stats(@dates[0], @dates[1], table_view)
    if table_view
      @header = ["Date"] + @individual_memberships
      @data_array = []
      @user_usage_data.each do |individual|
        data = [individual.date]
        @individual_memberships.each do |membership|
          data << (individual.membership_name == membership ? "#{((individual.asset_size.to_i/1024/1024.0)*1000).round.to_f/1000} MB" : 0)
        end
        @data_array << data
      end
    end
  end

  def get_company_usage_data(table_view = false)
    @company_usage_data = Asset.get_company_usage_stats(@dates[0], @dates[1], table_view)
    if table_view
      @header = ["Date"] + @company_memberships
      @data_array = []
      @company_usage_data.each do |company|
        data = [company.date]
        @company_memberships.each do |membership|
          data << (company.membership_name == membership ? "#{((company.asset_size.to_i/1024/1024.0)*1000).round.to_f/1000} MB" : 0)
        end
        @data_array << data
      end
    end
  end

  def get_user_sevice_data(table_view = false)
    @user_service_data = UserService.get_service_stats(@dates[0], @dates[1], table_view)
    if table_view
      services = []
      Service.all.each do |service|
        services << service.name
      end
      @header = ["Date"] + services
      @data_array = []
      @user_service_data.each do |individual|
        data = [individual.date]
        services.each do |service|
          data << (individual.service_name == service ? individual.service_count : 0)
        end
        @data_array << data
      end
    end
  end

  def get_company_sevice_data(table_view = false)
    @company_service_data = BrandService.get_service_stats(@dates[0], @dates[1], table_view)
    if table_view
      services = []
      Service.all.each do |service|
        services << service.name
      end
      @header = ["Date"] + services
      @data_array = []
      @company_service_data.each do |individual|
        data = [individual.date]
        services.each do |service|
          data << (individual.service_name == service ? individual.service_count : 0)
        end
        @data_array << data
      end
    end
  end

  def get_individual_upgrade_stats(table_view = false)
    @upgrade_data = User.get_upgrade_stats(@dates[0], @dates[1], table_view)
    @individual_upgrade_data = @upgrade_data
    if table_view
      free = Membership.find_by_id(1)
      premium = Membership.find_by_id(2)
      @header = ["Date", "#{free.name} to #{premium.name}"]
      @data_array = []
      @individual_upgrade_data.each do |individual|
        @data_array << [individual.date, individual.from_to_count]
      end
    end
  end

  def get_company_upgrade_stats(table_view = false)
    @upgrade_data = Company.get_upgrade_stats(@dates[0], @dates[1], table_view)
    @company_upgrade_data = @upgrade_data
     if table_view
      small = Membership.find_by_id(3)
      mid = Membership.find_by_id(4)
      enterprise = Membership.find_by_id(5)
      conversions = [["#{small.name} to #{mid.name}", "3-4"],["#{small.name} to #{enterprise.name}", "3-5"],["#{mid.name} to #{enterprise.name}", "4-5"],["#{mid.name} to #{small.name}", "4-3"],["#{enterprise.name} to #{mid.name}", "5-4"],["#{enterprise.name} to #{small.name}", "5-3"]]
      @header = ["Date"] + conversions.collect{|conversion| conversion[0]}
      @data_array = []
      @company_upgrade_data.each do |company|
        data = [company.date]
        conversions.each do |conversion|
          data << (company.from_to == conversion[1] ? company.from_to_count : "0")
        end
        @data_array << data
      end
    end
  end

  def get_revenue_report(table_view = false)
    @revenue_report = Payment.get_revenue_report(@dates[0], @dates[1], table_view)
    if table_view
      memberships = []
      Membership.paid_plans.each do |membership|
        memberships << membership.name
      end
      @header = ["Date"] + memberships
      @data_array = []
      @revenue_report.each do |report|
        data = [report.date]
        memberships.each do |membership|
          data << (report.membership_name == membership ? "#{number_to_currency(report.amount)}" : "$0.00")
        end
        @data_array << data
      end
    end
  end

  def export_csv
    @dates = set_dates
    get_memberships
    case params[:type]
    when "user_stats" then
      @data_array = [[User.get_stats(1), User.get_stats(2), Company.get_stats(3), Company.get_stats(4), Company.get_stats(5), (Company.get_stats.to_i + User.get_stats.to_i)]]
      @header = Membership.all.collect(&:name) << "Total"
    when "payment_stats" then
      @data_array = [[number_to_currency(Payment.get_stats(1)), number_to_currency(Payment.get_stats(2)), number_to_currency(Payment.get_stats(3)), number_to_currency(Payment.get_stats(4)), number_to_currency(Payment.get_stats(5)),  number_to_currency(Payment.get_stats)]]
      @header = Membership.all.collect(&:name) << "Total"
    when "usage_by_service" then
      @data_array = [[bytes_to_mb(Stream.get_usage_stats(Service::SERVICES_ID[:twitter])), bytes_to_mb(Stream.get_usage_stats(Service::SERVICES_ID[:facebook])), bytes_to_mb(Stream.get_usage_stats(Service::SERVICES_ID[:youtube])), bytes_to_mb(Stream.get_usage_stats(Service::SERVICES_ID[:vimeo])), bytes_to_mb(Stream.get_usage_stats(Service::SERVICES_ID[:delicious])), bytes_to_mb(Stream.get_usage_stats(Service::SERVICES_ID[:stumbleupon])), bytes_to_mb(Stream.get_usage_stats(Service::SERVICES_ID[:flickr])), bytes_to_mb(Stream.get_usage_stats(8)), bytes_to_mb(Stream.get_usage_stats(Service::SERVICES_ID[:tumblr])), bytes_to_mb(Stream.get_usage_stats("edintity")), bytes_to_mb(Stream.get_usage_stats)]]
      @header = Service.all.collect{|service| "#{service.name}" } << "edintity" << "Total"
    when "usage_by_post_type" then
      @data_array = [[bytes_to_mb(Stream.get_usage_stats_by_post_type(PostType::POST_TYPE_ID[:blog])), bytes_to_mb(Stream.get_usage_stats_by_post_type(PostType::POST_TYPE_ID[:photo])), bytes_to_mb(Stream.get_usage_stats_by_post_type(PostType::POST_TYPE_ID[:link])),  bytes_to_mb(Stream.get_usage_stats_by_post_type(PostType::POST_TYPE_ID[:status_update])), bytes_to_mb(Stream.get_usage_stats_by_post_type(PostType::POST_TYPE_ID[:video])), bytes_to_mb(Stream.get_usage_stats_by_post_type)]]
      @header = PostType.all.collect{|post_type|  "#{post_type.name}"  } << "Total"
    when "stream_stats" then
      @data_array = [[ Stream.get_count_stats(Service::SERVICES_ID[:twitter]), Stream.get_count_stats(Service::SERVICES_ID[:facebook]), Stream.get_count_stats(Service::SERVICES_ID[:youtube]), Stream.get_count_stats(Service::SERVICES_ID[:vimeo]), Stream.get_count_stats(Service::SERVICES_ID[:delicious]), Stream.get_count_stats(Service::SERVICES_ID[:stumbleupon]), Stream.get_count_stats(Service::SERVICES_ID[:flickr]), Stream.get_count_stats(8), Stream.get_count_stats(Service::SERVICES_ID[:tumblr]), Stream.get_count_stats("edintity"), Stream.get_count_stats]]
      @header = Service.all.collect{|service|  "#{service.name}"  } << "edintity" << "Total"
    when "service_by_individual" then
      @data_array = [[UserService.count_by_service_id(Service::SERVICES_ID[:twitter]), UserService.count_by_service_id(Service::SERVICES_ID[:facebook]), UserService.count_by_service_id(Service::SERVICES_ID[:youtube]), UserService.count_by_service_id(Service::SERVICES_ID[:vimeo]), UserService.count_by_service_id(Service::SERVICES_ID[:delicious]), UserService.count_by_service_id(Service::SERVICES_ID[:stumbleupon]),  UserService.count_by_service_id(Service::SERVICES_ID[:flickr]), UserService.count_by_service_id(8), UserService.count_by_service_id(Service::SERVICES_ID[:tumblr]), "NA", UserService.count_by_service_id]]
      @header = Service.all.collect{|service|  "#{service.name}"  } << "edintity" << "Total"
    when "service_by_company" then
      @data_array = [[BrandService.count_by_service_id(Service::SERVICES_ID[:twitter]), BrandService.count_by_service_id(Service::SERVICES_ID[:facebook]), BrandService.count_by_service_id(Service::SERVICES_ID[:youtube]), BrandService.count_by_service_id(Service::SERVICES_ID[:vimeo]), BrandService.count_by_service_id(Service::SERVICES_ID[:delicious]), BrandService.count_by_service_id(Service::SERVICES_ID[:stumbleupon]),  BrandService.count_by_service_id(Service::SERVICES_ID[:flickr]), BrandService.count_by_service_id(8), BrandService.count_by_service_id(Service::SERVICES_ID[:tumblr]), "NA", BrandService.count_by_service_id]]
      @header = Service.all.collect{|service|  "#{service.name}"  } << "edintity" << "Total"
    when "individual_user_signup" then
      get_individual_user_signup_data(true)
    when "company_user_signup" then
      get_company_user_signup_data(true)      
    when "company_user_usage" then
      get_company_usage_data(true)
    when "individual_user_usage" then
      get_user_usage_data(true)
    when "individual_user_service" then
      get_user_sevice_data(true)
    when "company_user_service" then
      get_company_sevice_data(true)
    when "individual_upgrade" then
      get_individual_upgrade_stats(true)
    when "company_upgrade" then
      get_company_upgrade_stats(true)
    when "revenue_report" then
      get_revenue_report(true)
    when "country_user_signup" then
      get_country_user_signup_data(true)
    when "post_method_usage" then
      get_post_method_usage_data(true)
    end
    csv_string = csv_data(@data_array, @header)
    send_data csv_string, :type => "text/csv",
      :filename=>"edintity_#{params[:name]}.csv",
      :disposition => 'attachment'
  end

  def get_memberships
    @individual_memberships = []
    Membership.individual.each do |membership|
      @individual_memberships << membership.name
    end
    @company_memberships = []
    Membership.business.each do |membership|
      @company_memberships << membership.name
    end
  end

  def csv_data(dash_board_data, header)
    csv_string = FasterCSV.generate do |csv|
      csv << header
      0.upto(dash_board_data.length - 1) { |count|
        csv << dash_board_data[count]
      }
    end
    csv_string
  end

  def set_dates
    @start_date = params[:start_date] || (Time.now - 15552000).strftime("%d/%m/%Y")
    @end_date = params[:end_date] || (Time.now).strftime("%d/%m/%Y")
    start_array = @start_date.split("/")
    end_array = @end_date.split("/")
    start_date = "#{start_array[2]}-#{start_array[1]}-#{start_array[0]} 00:00:00"
    end_date = "#{end_array[2]}-#{end_array[1]}-#{end_array[0]} 23:59:59"
    [start_date, end_date]
  end

  def create
    load_data
  end

  def get_service_usage_data
    service_usage_data = Asset.get_service_usage_stats(@dates[0], @dates[1])
    @flickr_data = service_usage_data["Flickr"]
    @facebook_data = service_usage_data["Facebook"]
    @tumblr_data = service_usage_data["Tumblr"]
    @youtube_data = service_usage_data["Youtube"]
    @vimeo_data = service_usage_data["Vimeo"]
  end
  
end

