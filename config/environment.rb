# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  %w(presenters).each do |folder|
    config.load_paths << File.join(Rails.root, 'app', folder)
  end
  

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  #config.gem 'authlogic'
  #config.gem "oauth"
  #config.gem "authlogic-oauth", :lib => "authlogic_oauth"

  config.gem "haml"
  config.gem 'will_paginate', :version => '2.3.15'
  config.gem 'authlogic'
  config.gem "oauth"
  config.gem "authlogic-oauth", :lib => "authlogic_oauth"
  #config.gem "refraction"
  #  config.gem "blackbook"
  config.gem "mechanize"
  config.gem "fastercsv",                 :version => '1.5.3'
  config.gem 'twitter_oauth'
  config.gem 'paperclip'
  config.gem 'contacts'
  config.gem "aws-s3", :lib => "aws/s3"
#  config.gem "aws-sdk"
  config.gem "flickraw"
  config.gem "responds_to_parent"
  config.gem "feedvalidator", :lib => 'feed_validator'
  config.gem "faraday"
  config.gem "oauth2"
  config.gem "facebook_oauth"
  #  config.gem "pauldix-feedzirra", :lib => "feedzirra", :source => "http://gems.github.com"

  config.gem "youtube-g", :lib => 'youtube_g'
  config.gem "matenia-tumblr-api", :lib => 'tumblr', :source => 'http://gemcutter.org'
  config.gem "vimeo"
  config.gem "rest-client", :lib => "rest_client"
  config.gem "tzinfo"
  #config.gem "zendesk-api"
  config.gem "refraction"
  config.gem "chronic"
  config.gem "packet"
  config.gem "rvideo"
  config.gem "ffmpeg"
  config.gem "youtube_it"
  config.gem "starling"
  config.gem "whenever"
#  config.gem "omniauth"
  config.gem "geoip"
  
  FlickRawOptions = {
    "api_key" => "f2396faae66f4d1cbda679c33808e5d4",
    "shared_secret" => "69f63b46da3f83e0"
  }
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  #  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  #    :default => '%m/%d/%Y',
  #    :date_time12  => "%m/%d/%Y %I:%M%p",
  #    :date_time24  => "%m/%d/%Y %H:%M"
  #  )

  config.after_initialize do
    Workling::Remote.dispatcher = Workling::Remote::Runners::StarlingRunner.new
    require File.join(Rails.root, 'app', 'presenters', 'base.rb')
    [
      File.join(RAILS_ROOT, 'lib', '*.rb'),
      File.join(RAILS_ROOT, 'lib', 'extensions', '**', '*.rb'),
      #      File.join(RAILS_ROOT, 'lib', 'blackbook', '**', '*.rb'),
      File.join(RAILS_ROOT, 'lib', 'forms', '**', '*.rb')
    ].each do |path|
      Dir.glob(path).each do |file|
        require file
      end
    end
    Dir[File.join(Rails.root, 'lib', 'patches', '**', '*.rb')].sort.each { |patch| require(patch) }
  end
  require 'fastpass'
  require 'active_merchant'
  require 'memcache'
  #Rails::Initializer.run do |config|
      
  #end
  # Defining variables
  EMAIL_HOST = "edintity.com"
  ZENDESK_OPTIONS = {
    "token" => "bThlI5armvBA6RBkizxyOmZbnP6Leb8217lZG0wUFUrFKwIV"
  }
  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
 

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  #ActionMailer::Base.delivery_method = :sendmail
end
