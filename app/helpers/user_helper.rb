module UserHelper
  require "tzinfo"
  def get_time_zones(country_code)
    zones = []
    begin
      time_zones = TZInfo::Country.get(country_code).zones
    rescue
      time_zones = TZInfo::Country.get("US").zones
    end
    zones = time_zones.collect{|zone| [zone, zone.name]} unless time_zones.blank?
    zones
  end
  
  def fetch_decrypted(membership, user, scope_from = "user")

    # cert_id is the certificate if we see in paypal when we upload our own certificates
    # cmd _xclick need for buttons
    # item name is what the user will see at the paypal page
    # custom and invoice are passthrough vars which we will get back with the asunchronous
    # notification
    # no_note and no_shipping means the client want see these extra fields on the paypal payment
    # page
    # return is the url the user will be redirected to by paypal when the transaction is completed.
    if params[:scope] == "user"
      payment_url = "http://edintity.com/users/payment_success?membership_id=#{membership.id}&user_id=#{user}&vendor=paypal&locale=#{session[:locale] || 'en'}"
    else
      payment_url = "http://edintity.com/company/payment_success?membership_id=#{membership.id}&company_id=#{user}&vendor=paypal&locale=#{session[:locale] || 'en'}"
    end
    decrypted = {
      "cert_id" => "LFK3GA2925TWC",
      "cmd" => "_xclick",
      "business" => "subith_1307522292_biz@sumerusolutions.com",
      "item_name" => "#{membership.name}",
      "item_number" => "1",
      "custom" =>"something to pass to IPN",
      "amount" => "#{membership.amount}",
      "currency_code" => "USD",
      "country" => "US",
      "no_note" => "1",
      "no_shipping" => "1",
      "return" => payment_url
    }
    @encrypted_basic = Crypto42::Button.from_hash(decrypted).get_encrypted_text.gsub("\n","")
    @action_url = ENV['RAILS_ENV'] == "production" ? "https://www.paypal.com/uk/cgi-bin/webscr" : "https://www.sandbox.paypal.com/uk/cgi-bin/webscr"
  end
end
