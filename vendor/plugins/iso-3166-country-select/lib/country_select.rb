# CountrySelect
module ActionView
  module Helpers
    module FormOptionsHelper
      # Return select and option tags for the given object and method, using country_options_for_select to generate the list of option tags.
      def country_select(object, method, priority_countries = nil, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_country_select_tag(priority_countries, options, html_options)
      end
      # Returns a string of option tags for pretty much any country in the world. Supply a country name as +selected+ to
      # have it marked as the selected option tag. You can also supply an array of countries as +priority_countries+, so
      # that they will be listed above the rest of the (long) list.
      #
      # NOTE: Only the option tags are returned, you have to wrap this call in a regular HTML select tag.
      def country_options_for_select(selected = nil, priority_countries = nil)
        country_options = ""

        if priority_countries
          country_options += options_for_select(priority_countries, selected)
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end

        return country_options + options_for_select(COUNTRIES, selected)
      end

COUNTRIES = [["Andorra", 'AD'], ["United Arab Emirates", 'AE'], ["Afghanistan", 'AF'], ["Antigua and Barbuda", 'AG'],
             ["Anguilla", 'AI'], ["Albania", 'AL'], ["Armenia", 'AM'], ["Netherlands Antilles", 'AN'],
             ["Angola", 'AO'], ["Antarctica", 'AQ'], ["Argentina", 'AR'], ["American Samoa", 'AS'],
             ["Austria", 'AT'], ["Australia", 'AU'], ["Aruba", 'AW'], ["Aland Islands Aland Islands", 'AX'],
             ["Azerbaijan", 'AZ'], ["Bosnia and Herzegovina", 'BA'], ["Barbados", 'BB'], ["Bangladesh", 'BD'],
             ["Belgium", 'BE'], ["Burkina Faso", 'BF'], ["Bulgaria", 'BG'], ["Bahrain", 'BH'],
             ["Burundi", 'BI'], ["Benin", 'BJ'], ["Saint Barthelemy Saint Barthelemy", 'BL'], ["Bermuda", 'BM'],
             ["Brunei Darussalam", 'BN'], ["Bolivia", 'BO'], ["Brazil", 'BR'], ["Bahamas", 'BS'],
             ["Bhutan", 'BT'], ["Bouvet Island", 'BV'], ["Botswana", 'BW'], ["Belarus", 'BY'],
             ["Belize", 'BZ'], ["Canada", 'CA'], ["Cocos (Keeling) Islands", 'CC'], ["Congo, the Democratic Republic of the", 'CD'],
             ["Central African Republic", 'CF'], ["Congo", 'CG'], ["Switzerland", 'CH'], ["Cote d'Ivoire Cote d'Ivoire", 'CI'],
             ["Cook Islands", 'CK'], ["Chile", 'CL'], ["Cameroon", 'CM'], ["China", 'CN'],
             ["Colombia", 'CO'], ["Costa Rica", 'CR'], #["Cuba", 'CU'],
             ["Cape Verde", 'CV'], ["Christmas Island", 'CX'], ["Cyprus", 'CY'], ["Czech Republic", 'CZ'], ["Germany", 'DE'],
             ["Djibouti", 'DJ'], ["Denmark", 'DK'], ["Dominica", 'DM'], ["Dominican Republic", 'DO'],
             ["Algeria", 'DZ'], ["Ecuador", 'EC'], ["Estonia", 'EE'], ["Egypt", 'EG'],
             ["Western Sahara", 'EH'], ["Eritrea", 'ER'], ["Spain", 'ES'], ["Ethiopia", 'ET'],
             ["Finland", 'FI'], ["Fiji", 'FJ'], ["Falkland Islands (Malvinas)", 'FK'], ["Micronesia, Federated States of", 'FM'],
             ["Faroe Islands", 'FO'], ["France", 'FR'], ["Gabon", 'GA'], ["United Kingdom", 'GB'],
             ["Grenada", 'GD'], ["Georgia", 'GE'], ["French Guiana", 'GF'], ["Guernsey", 'GG'],
             ["Ghana", 'GH'], ["Gibraltar", 'GI'], ["Greenland", 'GL'], ["Gambia", 'GM'],
             ["Guinea", 'GN'], ["Guadeloupe", 'GP'], ["Equatorial Guinea", 'GQ'], ["Greece", 'GR'],
             ["South Georgia and the South Sandwich Islands", 'GS'], ["Guatemala", 'GT'], ["Guam", 'GU'], ["Guinea-Bissau", 'GW'],
             ["Guyana", 'GY'], ["Hong Kong", 'HK'], ["Heard Island and McDonald Islands", 'HM'], ["Honduras", 'HN'],
             ["Croatia", 'HR'], ["Haiti", 'HT'], ["Hungary", 'HU'], ["Indonesia", 'ID'],
             ["Ireland", 'IE'], ["Israel", 'IL'], ["Isle of Man", 'IM'], ["India", 'IN'],
             ["British Indian Ocean Territory", 'IO'], ["Iraq", 'IQ'], #["Iran, Islamic Republic of", 'IR'],
             ["Iceland", 'IS'], ["Italy", 'IT'], ["Jersey", 'JE'], ["Jamaica", 'JM'], ["Jordan", 'JO'],
             ["Japan", 'JP'], ["Kenya", 'KE'], ["Kyrgyzstan", 'KG'], ["Cambodia", 'KH'],
             ["Kiribati", 'KI'], ["Comoros", 'KM'], ["Saint Kitts and Nevis", 'KN'], ["Korea, Democratic People's Republic of", 'KP'],
             ["Korea, Republic of", 'KR'], ["Kuwait", 'KW'], ["Cayman Islands", 'KY'], ["Kazakhstan", 'KZ'],
             ["Lao People's Democratic Republic", 'LA'], ["Lebanon", 'LB'], ["Saint Lucia", 'LC'], ["Liechtenstein", 'LI'],
             ["Sri Lanka", 'LK'], ["Liberia", 'LR'], ["Lesotho", 'LS'], ["Lithuania", 'LT'],
             ["Luxembourg", 'LU'], ["Latvia", 'LV'], ["Libyan Arab Jamahiriya", 'LY'], ["Morocco", 'MA'],
             ["Monaco", 'MC'], ["Moldova", 'MD'], ["Montenegro", 'ME'], ["Saint Martin (French part)", 'MF'],
             ["Madagascar", 'MG'], ["Marshall Islands", 'MH'], ["Macedonia, the former Yugoslav Republic of", 'MK'], ["Mali", 'ML'],
             #["Myanmar", 'MM'],
             ["Mongolia", 'MN'], ["Macao", 'MO'], ["Northern Mariana Islands", 'MP'],
             ["Martinique", 'MQ'], ["Mauritania", 'MR'], ["Montserrat", 'MS'], ["Malta", 'MT'],
             ["Mauritius", 'MU'], ["Maldives", 'MV'], ["Malawi", 'MW'], ["Mexico", 'MX'],
             ["Malaysia", 'MY'], ["Mozambique", 'MZ'], ["Namibia", 'NA'], ["New Caledonia", 'NC'],
             ["Niger", 'NE'], ["Norfolk Island", 'NF'], ["Nigeria", 'NG'], ["Nicaragua", 'NI'],
             ["Netherlands", 'NL'], ["Norway", 'NO'], ["Nepal", 'NP'], ["Nauru", 'NR'],
             ["Niue", 'NU'], ["New Zealand", 'NZ'], ["Oman", 'OM'], ["Panama", 'PA'],
             ["Peru", 'PE'], ["French Polynesia", 'PF'], ["Papua New Guinea", 'PG'], ["Philippines", 'PH'],
             ["Pakistan", 'PK'], ["Poland", 'PL'], ["Saint Pierre and Miquelon", 'PM'], ["Pitcairn", 'PN'],
             ["Puerto Rico", 'PR'], ["Palestinian Territory, Occupied", 'PS'], ["Portugal", 'PT'], ["Palau", 'PW'],
             ["Paraguay", 'PY'], ["Qatar", 'QA'], ["Reunion Reunion", 'RE'], ["Romania", 'RO'],
             ["Serbia", 'RS'], ["Russian Federation", 'RU'], ["Rwanda", 'RW'], ["Saudi Arabia", 'SA'],
             ["Solomon Islands", 'SB'], ["Seychelles", 'SC'], #["Sudan", 'SD'],
             ["Sweden", 'SE'], ["Singapore", 'SG'], ["Saint Helena", 'SH'], ["Slovenia", 'SI'], ["Svalbard and Jan Mayen", 'SJ'],
             ["Slovakia", 'SK'], ["Sierra Leone", 'SL'], ["San Marino", 'SM'], ["Senegal", 'SN'],
             ["Somalia", 'SO'], ["Suriname", 'SR'], ["Sao Tome and Principe", 'ST'], ["El Salvador", 'SV'],
             #["Syrian Arab Republic", 'SY'],
             ["Swaziland", 'SZ'], ["Turks and Caicos Islands", 'TC'], ["Chad", 'TD'],
             ["French Southern Territories", 'TF'], ["Togo", 'TG'], ["Thailand", 'TH'], ["Tajikistan", 'TJ'],
             ["Tokelau", 'TK'], ["Timor-Leste", 'TL'], ["Turkmenistan", 'TM'], ["Tunisia", 'TN'],
             ["Tonga", 'TO'], ["Turkey", 'TR'], ["Trinidad and Tobago", 'TT'], ["Tuvalu", 'TV'],
             ["Taiwan, Province of China", 'TW'], ["Tanzania, United Republic of", 'TZ'], ["Ukraine", 'UA'], ["Uganda", 'UG'],
             ["United States Minor Outlying Islands", 'UM'], ["United States", 'US'], ["Uruguay", 'UY'], ["Uzbekistan", 'UZ'],
             ["Holy See (Vatican City State)", 'VA'], ["Saint Vincent and the Grenadines", 'VC'], ["Venezuela", 'VE'], ["Virgin Islands, British", 'VG'],
             ["Virgin Islands, U.S.", 'VI'], ["Viet Nam", 'VN'], ["Vanuatu", 'VU'], ["Wallis and Futuna", 'WF'],
             ["Samoa", 'WS'], ["Yemen", 'YE'], ["Mayotte", 'YT'], ["South Africa", 'ZA'],
             ["Zambia", 'ZM'], ["Zimbabwe", 'ZW']]
      COUNTRIES = COUNTRIES.sort
      
      # All the countries included in the country_options output.
#      COUNTRIES = ["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola",
#        "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria",
#        "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin",
#        "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Bouvet Island", "Brazil",
#        "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia",
#        "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China",
#        "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo",
#        "Congo, the Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba",
#        "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt",
#        "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)",
#        "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia",
#        "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea",
#        "Guinea-Bissau", "Guyana", "Haiti", "Heard and McDonald Islands", "Holy See (Vatican City State)",
#        "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran, Islamic Republic of", "Iraq",
#        "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya",
#        "Kiribati", "Korea, Democratic People's Republic of", "Korea, Republic of", "Kuwait", "Kyrgyzstan",
#        "Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya",
#        "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia, The Former Yugoslav Republic Of",
#        "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique",
#        "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova, Republic of",
#        "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru",
#        "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger",
#        "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau",
#        "Palestinian Territory, Occupied", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines",
#        "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation",
#        "Rwanda", "Saint Barthelemy", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia",
#        "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino",
#        "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore",
#        "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa",
#        "South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "Sudan", "Suriname",
#        "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic",
#        "Taiwan, Province of China", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Timor-Leste",
#        "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan",
#        "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom",
#        "United States", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela",
#        "Viet Nam", "Virgin Islands, British", "Virgin Islands, U.S.", "Wallis and Futuna", "Western Sahara",
#        "Yemen", "Zambia", "Zimbabwe"] unless const_defined?("COUNTRIES")
    end
    
    class InstanceTag
      def to_country_select_tag(priority_countries, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag("select",
          add_options(
            country_options_for_select(value, priority_countries),
            options, value
          ), html_options
        )
      end
    end
    
    class FormBuilder
      def country_select(method, priority_countries = nil, options = {}, html_options = {})
        @template.country_select(@object_name, method, priority_countries, options.merge(:object => @object), html_options)
      end
    end
  end
end