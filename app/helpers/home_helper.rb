module HomeHelper

  def custom_tab_header(custom_tab)
    header = []
    unless custom_tab.service_ids.blank?
      services = custom_tab.services
      services.each do |service|
        header << image_tag("services/#{service.name.downcase}.png", :width => "15" )
      end
    end
    
    unless custom_tab.user_type_ids.blank?
      user_types = custom_tab.user_type_ids.split(",")
      user_types.each do |user_type|
        header << User::USER_TYPE_ID.index(user_type.to_i).to_s.capitalize
      end
    end

    header.join(", ")
  end

  def service_filter(service)
    user_services = current_user.active_services.find_all_by_service_id(service.id)
    if user_services.blank?
      [ image_tag("services/#{service.name.downcase}.png", :title => "#{service.name}", :width => "20px"), 0]
    else
      [ image_tag("services/#{service.name.downcase}.png", :title => "#{service.name}", :width => "20px"), user_services.count]
    end
    
  end

  def brand_service_filters(service)
    brand = @brand.is_default? ? @brand.company : @brand
    brand_services = brand.active_services.find_all_by_service_id(service.id)
    if brand_services.blank?
      [ image_tag("services/#{service.name.downcase}.png", :title => "#{service.name}", :width => "20px"), 0]
    else
      [ image_tag("services/#{service.name.downcase}.png", :title => "#{service.name}", :width => "20px"), brand_services.count]
    end
  end

  def get_feature_wrapper_class(member)
    "#{member.membership_type == 'business' ? (member.name == 'Platinum' ? 'featuresPriceWrapper last' : (member.name == 'Bronze' ? 'featuresPriceWrapper blueWrapper' : 'featuresPriceWrapper')) : 'featuresPriceWrapper'}"
  end

  def pricing_submit_button(button_label, pricing_plan)
    if button_label.blank?
      if current_user && pricing_plan.membership_type != "individual"
        return link_to "#{ pricing_plan.membership_type == "individual" ? t(:choose_this_plan) : "#{t(:free_trial_no_cc)}" }", new_company_path(:membership_id => pricing_plan.id)
      else
        return link_to "#{ pricing_plan.membership_type == "individual" ? t(:choose_this_plan) : "#{t(:free_trial_no_cc)}" }", new_user_path(:membership_id => pricing_plan.id)
      end
    else
      if pricing_plan.membership_type == "individual"
        if pricing_plan.name == "Premium"
          link_to_remote_redbox button_label, {:url => {:controller => :users, :action => :upgrade_to_premium, :membership_id => pricing_plan.id}}
        else
          link_to_remote_redbox button_label, {:url => {:controller => :users, :action => :downgrade_confirm}}
        end
      else
        if pricing_plan.amount.to_i <= @company.membership.amount.to_i
          link_to_remote_redbox "#{t :downgrade_plan} ", :url => down_or_upgrade_companies_path(:id => @company.id, :membership_id => pricing_plan.id, :membership_scope => "Downgrade")
        else
          link_to_remote_redbox "#{t :upgrade_plan}", :url => down_or_upgrade_companies_path(:id => @company.id, :membership_id => pricing_plan.id, :membership_scope => "Upgrade")
        end
      end
    end
  end
end
