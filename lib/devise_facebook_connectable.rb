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
  mattr_accessor :facebook_skip_create
  @@facebook_skip_create = false
end

# Load core I18n locales: en
#
I18n.load_path.unshift File.expand_path(File.join(File.dirname(__FILE__), *%w[devise_facebook_connectable locales en.yml]))

# Add +:facebook_connectable+ serializers and strategies to defaults.
#
Devise::STRATEGIES.unshift :facebook_connectable
Devise::SERIALIZERS.unshift :facebook_connectable
Devise::CONTROLLERS[:sessions].unshift :facebook_connectable

# PATCH:BEGIN: Very temporary one, while awaiting Devise 0.7.2.
Devise::Models.module_eval do
  def devise(*modules)
    raise "You need to give at least one Devise module" if modules.empty?
    
    options  = modules.extract_options!
    modules  = Devise.all if modules.include?(:all)
    modules -= Array(options.delete(:except))
    # PATCH: REMOVED: modules  = Devise::ALL & modules
    
    Devise.orm_class.included_modules_hook(self, modules) do
      modules.each do |m|
        devise_modules << m.to_sym
        include Devise::Models.const_get(m.to_s.classify)
      end
      
      options.each { |key, value| send(:"#{key}=", value) }
    end
  end
end
# PATCH:END
