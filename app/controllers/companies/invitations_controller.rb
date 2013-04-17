class Companies::InvitationsController < ApplicationController

  def invite_friends
    unless params[:invites].blank?
      @company =  Company.find_by_id(params[:company_id])
      @company_invitation = CompanyInvitation.create(:company_id => params[:company_id], :brand_id => params[:brand_id], :access_type => params[:access_type_id], :invitee_email_address => params[:invites])
      friend = params[:invites]
      Notifier.deliver_invite_friend(friend, current_user)
      render :update do |page|
#        if !@company.is_allowed_to_add_user_group?
#          page << "$j('.brand_invite_btn').html('<div class=\"blueBtn flRight\">#{link_to(t(:invite), "javascript:void(0)", :class => "smlrBtn", :title => "You have exceed your invite limit, please upgrade your account to inivite unlimited users", :onclick => "alert(\"You have exceed your invite limit, please upgrade your account to inivite unlimited users\")")}</div>');"
#        end
        page.replace_html "email_brand_invite_#{params[:id]}", "<div class='greenBtn flRight'><a class='smlrBtn' href='javascript:void(0)'>Invited</a></div>"
      end
    else
      render :update do |page|
        page << "notice('#{t :select_atleast_a_contact}');"
      end
    end
  end
  
end
