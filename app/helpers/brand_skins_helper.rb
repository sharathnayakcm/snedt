module BrandSkinsHelper
  def your_skin_for_brand
    content = capture_haml do
      haml_tag :div, :class => "skin_menu" do
        haml_tag :ul, :id => "menu_skin" do
          haml_tag :li do
            haml_tag :dl, :class => "" do
              haml_tag :dt do
                haml_tag :a, :href => "javascript:void(0)" do
                  haml_concat "Your Skins #{image_tag("arrow-down.png", :width => "15", :height => "15",:class => "icon_down", :onClick => "$j('.my_skins').slideToggle();$j(function(){$j('.icon_down').attr('src', swapImage );});return true;", :style => "float:right;margin:2px; margin-left:10px;")}"
                end
              end
              haml_tag :dd, :class => "my_skins", :style => "display:none" do
                haml_concat "#{link_to("#{image_tag("add_skin.png", :width => "15", :height => "15", :style => "")}", "javascript:void(0)", :onclick => "$j('#new_skin_name_div').show();")}"
                haml_concat "#{link_to("Add New Skin", "javascript:void(0)", :onclick => "$j('#new_skin_name_div').slideDown('slow');", :class => "my_skins_link")}"
              end
              haml_tag :div, :id =>'new_skin_name_div', :style => "text-align:center;background-image: url('/images/skin_header.jpg');background-repeat: repeat-x;width:287px;" do
                haml_tag :div, :class =>'name_label', :style => '' do
                  haml_concat "#{t :enter_skin_name}"
                  haml_concat ":"
                  haml_concat "#{text_field_tag 'new_skin_name','',:size => 11}"
                  haml_tag :div, :class =>"popup_button", :style => "text-align:center;padding-bottom:3px;padding-top:3px;" do
                    haml_concat "#{link_to_remote_with_loader "#{t :save}", :url => {:controller => :brand_skins, :action => :create}, :with => "'brand_id=#{@brand.id}&name='+$('new_skin_name').value"} &nbsp;&nbsp;"
                    haml_concat "#{link_to "#{t :cancel}", 'javascript:void(0)', :onclick =>"$j('#new_skin_name_div').slideUp('slow');"}"
                  end
                end
              end
              haml_tag :dd, :class => "my_skins", :style => "display:none; margin-top: -1px;" do
                if @brand.active_skin.blank?
                  haml_concat "<span Style='margin-bottom:2px;'>#{@default_skin.name.humanize}</span>"
                  haml_concat "#{image_tag("ok_green.png", :height => "20px", :title => "Active Skin")}"
                else
                  haml_concat "#{@default_skin.name} #{link_to(image_tag("power_black.png", :widht => "18", :height => "18", :title => "Apply Skin"), :controller => :profiles, :action => :apply_skin, :skin_id => @default_skin.id, :class => "my_skins_link")}"
                end
              end
              @my_skins.each do |skin|
                haml_tag :dd, :class => "my_skins", :style => "display:none; margin-top: -1px;" do
                  if @brand.active_skin_id == skin.id
                    haml_concat "#{skin.name} #{image_tag("ok_green.png", :height => "20px", :title => "Active Skin")}"
                  else
                    haml_concat "#{skin.name} #{link_to(image_tag("power_black.png", :widht => "18", :height => "18", :title => "Apply Skin"), apply_skin_brand_path(:id => @brand.id, :skin_id => skin.id))} #{link_to_remote_with_loader(image_tag("delete_black.png", :widht => "18", :height => "18", :title => "Delete Skin"), :url => {:controller => :brand_skins, :action => :delete_skin, :skin_id => skin.id, :brand_id => @brand.id})}"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
