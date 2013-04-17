class Admin::UploadsController < ApplicationController
  before_filter :require_user
  before_filter :admin_required
  def index
    @upload_setting = UploadSetting.first
  end

  def update_setting
    upload_setting = UploadSetting.first
    upload_setting.update_attributes({:video_size => params[:video_size].to_i, :photo_size => params[:photo_size].to_i})
    redirect_to :action => :index
  end

end
