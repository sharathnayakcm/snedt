#require "refraction"
#if RAILS_ENV == "production"
#  Refraction.configure do |req|
#    host = (req.host).split('.')
#    case req.host
#    when /([-\w]+\.)?edintity\.com/
#      req.rewrite! "https://edintity.com#{req.env["REQUEST_URI"]}"
#      #    passthrough with no change
#    when /([-\a-z]+\.)?edintity\.com/
#      if host.first == "support"
#        req.rewrite! "https://edintity.com/zendesk"
#      elsif host.first == "community"
#        req.rewrite! "http://getsatisfaction.com/edintity"
#      else
#        req.rewrite! "https://edintity.com/profiles/#{host.first}"
#      end
#    else  # wildcard domains (e.g. pivotalabs.com)
#      req.permanent! :host => "edintity.com", :scheme => "https"
#    end
#  end
#else
#  Refraction.configure do |req|
#    host = (req.host).split('.')
#    case req.host
#    when /([-\w]+\.)?ed\.com/
#      req.rewrite! "http://ed.com:3000#{req.env["REQUEST_URI"]}"
#      #    passthrough with no change
#    when /([-\a-z]+\.)?ed\.com/
#      if host.first == "support"
#        req.rewrite! "http://ed.com:3000/zendesk"
#      elsif host.first == "community"
#        req.rewrite! "http://getsatisfaction.com:3000/edintity"
#      else
#        req.rewrite! "http://ed.com:3000/profiles/#{host.first}"
#      end
#    else  # wildcard domains (e.g. pivotalabs.com)
#      req.permanent! :host => "ed.com:3000", :scheme => "http"
#    end
#  end
#end
##
