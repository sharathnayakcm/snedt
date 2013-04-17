class VideoUploadWorker < Workling::Base
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def upload_to_services(args = {})
    begin
      if args[:file_path]
        flv_video = Asset.convert_video(args[:file_path], args[:stream])
        file = flv_video[1]
        unless file.blank?
          asset = Asset.new({:video => file})
          asset.user_id = args[:user]
          unless args[:params][:company_id].blank?
            asset.company_id = args[:params][:company_id]
          end
          if asset.save
            current_user = User.find_by_id(args[:user])
            ext = File.extname(file.original_filename)
            asset.update_attributes({:video_file_name => "originals#{ext}"})
            asset.update_attributes!({:attachable_id => args[:stream], :attachable_type => "Stream"})
            unless args[:params][:scope]
              services = current_user.user_services
            else
              brand = Brand.find_by_id(args[:params][:brand_id])
              services = brand.brand_services
            end
            stream = Stream.find_by_id(args[:stream])
            if args[:user_service_list]
              args[:params][:file_path] = flv_video[2]
              services.video_authorized.each do |service|
                if args[:user_service_list].include?(service.id.to_s)
                  url = "https://s3-eu-west-1.amazonaws.com/edintitydemo/uploads/videos/#{asset.id}/#{asset['video_file_name']}"
                  Post.post_video_to_service(args[:params],service,file,url,stream,args[:host])
                end
              end
              File.delete(flv_video[2])
            else
              File.delete(flv_video[2])
            end
            stream.update_attributes(:stream_created_at => Time.current, :video_status_id => Stream::VIDEO_STATUS["success"]) unless stream.blank?
          end
        end
      end
    rescue Exception => e
      stream = Stream.find_by_id(args[:stream])
      stream.update_attributes(:stream_created_at => Time.current, :video_status_id => Stream::VIDEO_STATUS["success"])
    end
  end

end

