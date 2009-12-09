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
require 'devise_facebook_connectable/controller_filters'
require 'devise_facebook_connectable/routes'
require 'devise_facebook_connectable/view_helpers'

module Devise
  module FacebookConnectable
    
    extend self
    
    mattr_accessor  :verbose
    
    # Logging helper: Internal debug-logging for the plugin.
    #
    def log(message, level = :info)
      return unless @@verbose
      level = :info if level.blank?
      @@logger ||= ::Logger.new(::STDOUT)
      @@logger.send(level.to_sym, "[devise/facebook_connectable:]  #{level.to_s.upcase}  #{message}")
    end
    
  end
end

# Load core I18n locales: en
#
I18n.load_path.unshift File.expand_path(File.join(File.dirname(__FILE__), *%w[devise_facebook_connectable locales en.yml]))

# Add +:facebook_connectable+ serializers and strategies to defaults.
#
Devise::STRATEGIES.unshift :facebook_connectable
Devise::SERIALIZERS.unshift :facebook_connectable
# Devise::CONTROLLERS.unshift :facebook_connectable # TODO: Wait for Devise 0.7.2 release.

# Override to get Devise to get that SessionsController should be used for both
# :facebook_connectable and :authenticatable. Controller-logic is the same.
#
Devise::Mapping.class_eval do

  def allows?(controller)
    (self.for & [Devise::CONTROLLERS[controller.to_sym], :facebook_connectable].flatten).present?
  end

end
