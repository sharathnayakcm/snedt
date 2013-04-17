module DropDownMenuHelper
  def dropdownmenu_for(caption, lists = [], options = {})
    if session[:locale] == 'arabic'
      left_align = caption == "." ? 15 : 11
    else
      left_align = caption == "." ? 555 : 10
    end
   
    lists = lists.compact

    options.assert_valid_keys_and_reverse_merge!(
      :tooltip_text => '')
    id_count = rand(100)
    capture_haml do
      haml_concat javascript_tag("qmad.qm#{id_count} = new Object();")
      haml_tag :div, :id => "qm#{id_count}", :class => "qm0 menu_parent qmmc", :style => "margin-top:-8px;" do
        haml_concat link_to caption, "javascript: void(0);", {:class => "qmparent", :title => options[:tooltip_text]}
        haml_tag :div, :class => "menu_child" do
          haml_concat lists
        end
      end
      haml_concat javascript_tag("qm_create(#{id_count},false,0,300,false,#{left_align})")
    end
  end
end