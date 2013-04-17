class Companies::FollowersController < ApplicationController
  before_filter :require_user

  def follow
    @brand = Brand.find(params[:id])
    @brand.followers.create(:company_id => @brand.company_id, :user_id => params[:user_id])
    if params[:find_friends_page]
      render :update do |page|
        page.replace_html "on_edintity_#{params[:id]}", :partial => "users/friends/edintity_brands", :locals => {:user => @brand}
        page << "notice('You are now following #{@brand.name}.');"
      end
    elsif params[:search_page]
      render :update do |page|
        page.replace_html "brand_follow_unfollow_#{@brand.id}", link_to_remote(t(:unfollow), {:url => unfollow_company_followers_path(:company_id => @brand.company_id, :id => @brand.id, :user_id => current_user.id, :search_page => true), :method => :get}, :class=>"smlrBtn")
        page << "$j('#brand_follow_unfollow_#{@brand.id}').attr('class', 'yellowBtn')"
        page << "notice('You are now following #{@brand.name}')"
      end
    else
      render :update do |page|
        page.replace_html "follow_unfollow_btn", link_to_remote(t(:unfollow), {:url => unfollow_company_followers_path(:company_id => @brand.company_id, :id => @brand.id, :user_id => current_user.id), :method => :get}, :id=>"unFollowBtn")
        page << "notice('You are now following #{@brand.name}')"
        page.replace_html "brand_followers_count", params[:scope].blank? ? @brand.followers.count : current_user.company_followers.count
      end
    end
  end

  def unfollow
    @brand = params[:brand_id].blank? ? Brand.find(params[:id]) : Brand.find(params[:brand_id])
    company_followers = @brand.followers.find(:first, :conditions => ["user_id = ?", params[:user_id]])
    company_followers.destroy unless company_followers.blank?
    if params[:find_friends_page]
      render :update do |page|
        page.replace_html "on_edintity_#{params[:id]}", :partial => "users/friends/edintity_brands", :locals => {:user => @brand}
        page << "notice('You are now following #{@brand.name}.');"
      end
    else
      render :update do |page|
        if params[:listing_page]
          page << "notice('You are no longer following #{@brand.name}')"
          page << "$j('#following_brand_#{@brand.id}').remove();"
          page.replace_html "brandCount", "<h4 class='flLeft'>You follow #{current_user.company_followers.reload.count} brands</h4>"
        elsif params[:search_page]
          page.replace_html "brand_follow_unfollow_#{@brand.id}", link_to_remote(t(:follow), {:url => follow_company_followers_path(:company_id => @brand.company_id, :id => @brand.id, :user_id => current_user.id, :search_page => true), :method => :get}, :class=>"smlrBtn")
          page << "$j('#brand_follow_unfollow_#{@brand.id}').attr('class', 'blueBtn')"
          page << "notice('You are no longer following #{@brand.name}')"
        else
          unless company_followers.blank?
            page.replace_html "follow_unfollow_btn", link_to_remote(t(:follow), {:url => follow_company_followers_path(:company_id => @brand.company_id, :id => @brand.id, :user_id => current_user.id), :method => :get}, :id=>"unFollowBtn")
            page << "notice('You are no longer following #{@brand.name}')"
            page.replace_html "brand_followers_count", params[:scope].blank? ? @brand.followers.count : current_user.company_followers.count
          end
        end
      end
    end
  end
end
