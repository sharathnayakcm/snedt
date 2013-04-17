module SkinsHelper

  def style_attribute_field(panel_type, style_attribute, skin_styles)
    case style_attribute.name
    when 'background-color'
      text_field_tag "#{panel_type.name}[#{style_attribute.name}]", "#{skin_styles["#{panel_type.name}_background-color"] || '#17404E'}", {:id => "color#{style_attribute.id}_#{panel_type.id}", "data-text" => "hidden", :style => "height:20px;width:20px;", :type => "color", :onchange => "changeStyle('#{style_attribute.name}', '#{panel_type.element_name}', this.value)"}
    when 'background-image'
      render :partial => "skins/upload_form", :locals => { :file_id => "skin_form_#{panel_type.id}", :panel_type => panel_type }
    when 'text-transform'
      select_tag "#{panel_type.name}[#{style_attribute.name}]", options_for_select(["none", "capitalize", "lowercase", 'uppercase', 'inherit'],skin_styles["#{panel_type.name}_text-transform"]), {:onchange => "changeStyle('#{style_attribute.name}', '#{panel_type.element_name}', this.value)"}
      #              capture_haml do
      #          haml_tag :div, :class => "selected rounded postinner", :style => "display:block;" do
      #            select_tag "#{panel_type.name}[#{style_attribute.name}]", options_for_select(["medium", "small", "large"]), {:onchange => "changeFontSize('#{panel_type.name}_#{style_attribute.name}')", :class => "rounded"}
      #          end
      #          haml_tag :div, :class => "postright" do
      #            image_tag("images_1/pickright.png")
      #          end
      #      end
    when 'font-style'
      select_tag "#{panel_type.name}[#{style_attribute.name}]", options_for_select(["normal", "italic", "inherit"],skin_styles["#{panel_type.name}_font-style"]), :onchange =>  "changeStyle('#{style_attribute.name}', '#{panel_type.element_name}', this.value)"
    when 'font-family'
      select_tag "#{panel_type.name}[#{style_attribute.name}]", options_for_select(["Tahoma,Geneva,sans-serif", "inherit","Arial", "Comic", "Georgia", "Tahoma", "Verdana", "Times New Roman", "Trebuchet", "Lucida Grande", "Helvetica", "san-serif", "serif", "cursive", "fantasy", "monospace"],skin_styles["#{panel_type.name}_font-family"]), :onchange => "changeStyle('#{style_attribute.name}', '#{panel_type.element_name}', this.value)"
    when 'color'
      links = panel_type.name == 'body' ? '' : panel_type.element_name.gsub(',',' a,') + " a"
      text_field_tag "#{panel_type.name}[#{style_attribute.name}]", "#{skin_styles["#{panel_type.name}_color"] || '#FFFFFF'}", {:id => "color#{style_attribute.id}_#{panel_type.id}", "data-text" => "hidden", :style => "height:20px;width:20px;", :type => "color", :onchange =>  "changeStyle('#{style_attribute.name}', '#{panel_type.element_name}, #{links}', this.value)"}
    when 'border'
      color = skin_styles["#{panel_type.name}_border"] ? skin_styles["#{panel_type.name}_border"].gsub("1px solid ", '') : '#17404E'
      text_field_tag "#{panel_type.name}[#{style_attribute.name}]", "#{color}", {:id => "color#{style_attribute.id}_#{panel_type.id}", "data-text" => "hidden", :style => "height:20px;width:20px;", :type => "color", :onchange =>  "changeStyle('#{style_attribute.name}', '#{panel_type.element_name}', 'solid 1px '+this.value)"}
    when 'background-repeat'
      select_tag "#{panel_type.name}[#{style_attribute.name}]", options_for_select([["None", "no-repeat"], ["Horrizontal", "repeat-x"], ["Vertical", "repeat-y"], ["Both", "repeat"]],skin_styles["#{panel_type.name}_background-repeat"]), :onchange =>  "changeStyle('#{style_attribute.name}', '#{panel_type.element_name}', this.value)"
    end
  end


  def your_skin
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
                    haml_concat "#{link_to_remote_with_loader "#{t :save}", :url => {:controller => :skins, :action => :create}, :with => "'name='+$('new_skin_name').value"} &nbsp;&nbsp;"
                    haml_concat "#{link_to "#{t :cancel}", 'javascript:void(0)', :onclick =>"$j('#new_skin_name_div').slideUp('slow');"}"
                    end
                  end
                end
              haml_tag :dd, :class => "my_skins", :style => "display:none; margin-top: -1px;" do
                if current_user.active_skin.blank?
                  haml_concat "<span Style='margin-bottom:2px;'>#{@default_skin.name.humanize}</span>"
                  haml_concat "#{image_tag("ok_green.png", :height => "20px", :title => "Active Skin")}"
                else
                  if controller_name == "profiles" || controller_name == "skins"
                    haml_concat "#{@default_skin.name} #{link_to(image_tag("power_black.png", :widht => "18", :height => "18", :title => "Apply Skin"), :controller => :profiles, :action => :apply_skin, :skin_id => @default_skin.id, :class => "my_skins_link")}"
                  else
                    haml_concat "#{@default_skin.name} #{link_to(image_tag("power_black.png", :widht => "18", :height => "18", :title => "Apply Skin"), apply_skin_brand_path(:skin_id => @default_skin.id), :class => "my_skins_link")}"
                  end
                end
              end
              @my_skins.each do |skin|
                haml_tag :dd, :class => "my_skins", :style => "display:none; margin-top: -1px;" do
                  if @brand.blank?
                    if current_user.active_skin == skin
                      haml_concat "#{skin.name} #{image_tag("ok_green.png", :height => "20px", :title => "Active Skin")}"
                    else
                      haml_concat "#{skin.name} #{link_to(image_tag("power_black.png", :widht => "18", :height => "18", :title => "Apply Skin"), :controller => :profiles, :action => :apply_skin, :skin_id => skin.id)} #{link_to_remote_with_loader(image_tag("delete_black.png", :widht => "18", :height => "18", :title => "Delete Skin"), :url => {:controller => :skins, :action => :delete_skin, :skin_id => skin.id})}"
                    end
                  else
                    if @brand.active_skin_id == skin.id
                      haml_concat "#{skin.name} #{image_tag("ok_green.png", :height => "20px", :title => "Active Skin")}"
                    else
                      haml_concat "#{skin.name} #{link_to(image_tag("power_black.png", :widht => "18", :height => "18", :title => "Apply Skin"), apply_skin_brand_path(:skin_id => skin.id))} #{link_to_remote_with_loader(image_tag("delete_black.png", :widht => "18", :height => "18", :title => "Delete Skin"), :url => {:controller => :skins, :action => :delete_skin, :skin_id => skin.id})}"
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
end
