class Admin::CompaniesController < AdminController
  before_filter :require_user
  before_filter :admin_required

  def index
    load_companies
    render :layout => false if request.xhr?
  end

  def new
    @company = Company.new
    @header = "New Company"
    #    @timezone = TimeZone.new()
    #    raise @timezone.inspect
  end

  def create
    @company = Company.new(params[:company])
    if @company.save
#      Notifier.deliver_activation_instructions(@company)
      flash[:notice] = "#{t :account_created}"
      redirect_to admin_companies_path
    else
      render :action => :new
    end
  end

  def edit
    @company = Company.find(params[:id])
    @header = "Edit Company"
    init_edit
  end

  def update
    @company = Company.find(params[:id])
    if @company.update_attributes(params[:company])
      flash[:notice] = "#{t :company_updated}"
      redirect_to admin_companies_path(current_user)
    else
      init_edit
      flash[:notice] = "#{t :company_not_updated}"
      render :action => :edit
    end

  end

  def user_validation
    unless params[:user_name].blank?
      @existing_user = Company.find_all_by_user_name(params[:user_name])
      if @existing_user.blank?
        render :text => false, :layout => false
      else
        render :text => true, :layout => false
      end
    else
      render :text => 'blank', :layout => false
    end
    return
    if params[:password]
      @existing_user = Company.find_all_by_user_name(params[:password])
      if @existing_user.blank?
        @validate_user_status = "<font color='green'><b>#{t :incorrect_pwd}</b></font>"
      else
        @validate_user_status = "<font color='green'><b>#{t :correct_pwd}</b></font>"
      end
    end
    render :layout => false
  end

  def init_edit
  end

  #fifth action of signup wizard page
  def done
    @current_user.update_attribute(:done, "1")
    @current_user.update_attribute(:privacy_type_id, params[:privacy_type_id])
  end


  def toggle_active
    company = Company.find(params[:id])
    company.toggle!(:active)
    company.update_attribute(:deleted_at, nil) if company.active
    render :update do |page|
      page.replace_html "company_deleted_#{company.id}", ""
      page << "notice('Status updated successfully')"
    end
  end



  def destroy
    @company = Company.find(params[:id])
    @company.destroy
    render :update do |page|
      page << "Effect.Fade('company_#{@company.id}')"
    end
  end

  private


  def load_companies
    @company_table = Grid::Admin::CompaniesPresenter.new(@template)
    if params[:search_key].blank?
    @companies = Company.all(:order => @company_table.order)
    else
      @companies = Company.find(:all, :conditions => ["name like ? OR url like ?", "#{params[:search_key]}%", "%#{params[:search_key]}%"], :order => @company_table.order)
    end
    @companies = @companies.paginate(:per_page => params[:per_page].to_i > 0 ? params[:per_page] : 10, :page => @company_table.page || (params[:page].blank? ? 1 : params[:page]), :total_entries => @companies.size)
  end

end


