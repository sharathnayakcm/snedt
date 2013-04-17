# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_SNFA_session',
  :secret      => 'ffdad98424498afd68103f53425d5423f52ee478a80ab443650cb69afd77437b8968fb8cccc9d742925103139a441874307a1c8e1ad7ae33f3c5997a34bfa68d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
