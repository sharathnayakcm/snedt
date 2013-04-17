class StyleAttribute < ActiveRecord::Base

  named_scope :background, :conditions => "category = 'background'"
  named_scope :font, :conditions => "category = 'font'"

  TYPE_IDS={
    "background-color" => 1,
    "background-image" => 2,
    "text-transform" => 8,
    "font-style" => 3,
    "font-family" => 4,
    "color" => 5,
    "border" => 6,
    "background-repeat" => 7
  }

  TYPE_NAMES={
    1 => "background-color",
    2 => "background-image",
    3 => "font-style",
    4 => "font-family",
    5 => "color",
    6 => "border",
    7 => "background-repeat",
    8 => "text-transform"
  }

end
