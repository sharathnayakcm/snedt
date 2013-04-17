class Companies::DashboardController < ApplicationController

  def show
    load_instances
    @dates = set_dates
    get_company_brands_data
  end

  def load_data
    @dates = set_dates
    if (DateTime.parse(@dates[0]) > DateTime.parse(@dates[1]))
      render :update do |page|
        page << "notice('start date should not be greater than end date')"
      end
    else
      case params[:type]
      when "company" then
        get_companies_data(params[:category])
      when "brand" then
        get_brand_data(params[:category])
      when "stream" then
        get_streams_data
      end
    end
  end


  def get_companies_data(category)
    @brand = current_user.company.default_brand
    case category
    when "brands" then
      get_company_brands_data
    when "locations" then
      get_company_locations_data
    when "services" then
      get_company_services_data
    end
    render :update do |page|
      page.replace_html "graph_data",:partial => "companies/dashboard/company_#{category}"
      page << "dashBoardMenuHiglightion('company')"
    end
  end

  def get_brand_data(category)
    @company_brands = current_user.company.brands.blank? ? [] : current_user.company.brands.collect{|brand| [brand.id, brand.name]}
    @brand = params[:id].blank? ? current_user.company.default_brand : current_user.company.brands.find_by_id(params[:id])
    category = category.blank? ? "locations" : category
    case category
    when "locations" then
      get_brand_locations_data
    when "services" then
      get_brand_services_data
    end
    render :update do |page|
      page.replace_html "graph_data",:partial => "companies/dashboard/brand_#{category}"
      page << "dashBoardMenuHiglightion('brand')"
    end
  end

  def get_company_brands_data
    @company_brands_data = current_user.company.get_company_brands_data(@dates[0], @dates[1])
  end

  def get_company_locations_data
    @company_locations_data = current_user.company.get_locations_data(@dates[0], @dates[1])
  end

  def get_company_services_data
    services_data = Brand.get_services_data(@dates[0], @dates[1], 'company', current_user.company.id)
    @company_services_data = services_data[1]
    @total_followers = services_data[0]
  end

  def get_brand_locations_data
    @brand_locations_data = @brand ? @brand.get_locations_data(@dates[0], @dates[1]) : [['No data'], [[[DateTime.parse(@dates[0]).to_i*1000, 0], [DateTime.parse(@dates[1].gsub('23:59:59','00:00:00')).to_i*1000, 0]]]]
  end

  def get_brand_services_data
    services_data = @brand ? Brand.get_services_data(@dates[0], @dates[1], 'brand', @brand.id) : [['No data'], [[[DateTime.parse(@dates[0]).to_i*1000, 0], [DateTime.parse(@dates[1].gsub('23:59:59','00:00:00')).to_i*1000, 0]]]]
    @brand_services_data = services_data[1]
    @total_followers = services_data[0]
  end

  def get_streams_data
    @streams = current_user.company.get_top_streams(@dates[0], @dates[1], params[:filter], params[:limit].to_i)
    render :update do |page|
      page.replace_html "graph_data",:partial => "companies/dashboard/top_streams"
    end
  end

  def export_csv
    @dates = set_dates
    case params[:type]
    when "company_brands" then
      get_company_brands_data
      csv_string = csv_data(@company_brands_data)
    when "company_locations" then
      get_company_locations_data
      csv_string = csv_data(@company_locations_data)
    when "company_services" then
      get_company_services_data
      csv_string = csv_data(@company_services_data)
    when "brand_locations" then
      @brand = current_user.company.brands.find_by_id(params[:brand_id])
      get_brand_locations_data
      csv_string = csv_data(@brand_locations_data)
    when "brand_services" then
      @brand = current_user.company.brands.find_by_id(params[:brand_id])
      get_brand_services_data
      csv_string = csv_data(@brand_services_data)
    end
    send_data csv_string, :type => "text/csv",
      :filename=>"edintity_#{params[:name]}.csv",
      :disposition => 'attachment'
  end

  def csv_data(dash_board_data)
    csv_string = FasterCSV.generate do |csv|
      unless dash_board_data[0].blank?
        0.upto(dash_board_data[0].length - 1) { |i|
          csv << [dash_board_data[0][i]]
          csv << ["Date", "Followers"]
          dash_board_data[1][i].sort{|x,y| x[0] <=> y[0]}.each do |data|
            data[0] = Time.at(data[0]/1000).strftime("%b %d, %Y")
            csv << data unless data[1] == 0
          end
          csv << [""]
        }
      else
        csv << [""]
      end
    end
    csv_string
  end
  
  def set_dates
    @start_date = params[:start_date] || (Time.now - 15552000).strftime("%m/%d/%Y")
    @end_date = params[:end_date] || (Time.now).strftime("%m/%d/%Y")
    start_array = @start_date.split("/")
    end_array = @end_date.split("/")
    start_date = "#{start_array[2]}-#{start_array[0]}-#{start_array[1]} 00:00:00"
    end_date = "#{end_array[2]}-#{end_array[0]}-#{end_array[1]} 23:59:59"
    [start_date, end_date]
  end

  private

  def load_instances
    @user_tabs = current_user.active_tabs
    @user_unused_tabs = current_user.unused_tabs
    @company = Company.find(params[:company_id])
    @brand = @company.default_brand(:include => [{:company => [:membership]}, :subbrands, :streams]) unless @company.blank?
    @tab_name = "dashboard"
  end
end
