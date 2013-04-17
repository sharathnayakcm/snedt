class Companies::BrandUserGroupsController < ApplicationController

  before_filter :require_user

  def confirm_reqeust
    @brand = Brand.find(params[:brand_id])
    confirm = @brand.confirm_affliation_request(current_user)
    if confirm
      flash[:notice] = "Affilation request confirmed"
      redirect_to @brand.is_default? ? company_path(:id => @brand.company.name, :scope => 'affiliation') : company_brand_path(@brand.company, @brand.id)
    else
      flash[:notice] = "You are not authorized to access this information"
      redirect_to root_url
    end
  end

  def edit
    @brand = BrandUserGroup.find(params[:id])
    render :partial => "/companies/brands/brand_role"
  end

  def new
    @brand_user_group = BrandUserGroup.find(params[:id])
    @company = Company.find(params[:company_id])
    @brand_user_groups = @company.brand_user_groups
    attributes = {:access_type => params[:access_type_id]}
    if params[:access_type_id].to_i == BrandUserGroup::ACCESS_TYPES["Brand Admin"].to_i
      attributes[:brand_id] = nil
    else
      attributes[:brand_id] = params[:brand_id]
    end
    @brand_user_group.update_attributes(attributes)
    render :update do |page|
      flash[:notice] ="#{t :role_changed}"
      page.replace_html "user_roles",  :partial => "/companies/brands/user_roles"
    end
  end


  def destroy
    @brand_user_group = BrandUserGroup.find(params[:id], :include => [ {:company => [:brand_user_groups]}])
    @brand_user_group.delete
    @brand_user_groups = @brand_user_group.company.brand_user_groups.reload
    if request.xhr?
      @company = @brand_user_group.company
      if params[:membership_id]
        membership = Membership.find(params[:membership_id])
        render :update do |page|
          page << "Effect.Fade('brand_user_group_#{@brand_user_group.id}')"
          if @company.brand_user_groups.size - 1 > membership.user_count.to_i
            page << "notice('Delete #{@company.brand_user_groups.size - membership.user_count.to_i} more user(s) to continue downgrade')"
          else
            page << "$('downgrade_button').show()"
          end
        end
      else
        render :update do |page|
          flash[:notice] ="#{t :brand_role_deleted}"
          page.replace_html "user_roles",  :partial => "/companies/brands/user_roles"
        end
      end
    else
      flash[:notice] ="#{t :brand_role_deleted}"
      redirect_to edit_company_path(@brand_user_group.company)
    end
  end
end
