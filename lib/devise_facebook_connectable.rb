# encoding: utf-8
begin
  require 'devise'
rescue
  gem 'devise'
  require 'devise'
end

begin
  require 'facebooker'
rescue
  gem 'facebooker'
  require 'facebooker'
end

require 'devise_facebook_connectable/model'
require 'devise_facebook_connectable/serializer'
require 'devise_facebook_connectable/strategy'
require 'devise_facebook_connectable/schema'
require 'devise_facebook_connectable/routes'
require 'devise_facebook_connectable/controller_filters'
require 'devise_facebook_connectable/view_helpers'

module Devise
  # Specifies the name of the database column name used for storing
  # the user Facebook UID. Useful if this info should be saved in a
  # generic column if different authentication solutions are used.
  mattr_accessor :facebook_uid_field
  @@facebook_uid_field = :facebook_uid
  
  # Specifies the name of the database column name used for storing
  # the user Facebook session key. Useful if this info should be saved in a
  # generic column if different authentication solutions are used.
  mattr_accessor :facebook_session_key_field
  @@facebook_session_key_field = :facebook_session_key
  
  # Specifies if account should be created if no account exists for
  # a specified Facebook UID or not.
  mattr_accessor :facebook_auto_create_account
  @@facebook_auto_create_account = true
end

# Load core I18n locales: en
#
I18n.load_path.unshift File.join(File.dirname(__FILE__), *%w[devise_facebook_connectable locales en.yml])

# Add +:facebook_connectable+ serializers and strategies to defaults.
#
Devise::ALL.unshift :facebook_connectable
Devise::STRATEGIES.unshift :facebook_connectable
Devise::SERIALIZERS.unshift :facebook_connectable
#Devise::CONTROLLERS[:sessions].unshift :facebook_connectable
Devise::CONTROLLERS[:facebook_sessions] = [:facebook_connectable]
