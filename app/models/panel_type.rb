class PanelType < ActiveRecord::Base

  TYPE_NAMES={
    1 => "body",
    2 => "header",
    3 => "stream",
    4 => "right_content"
  }
  
end
