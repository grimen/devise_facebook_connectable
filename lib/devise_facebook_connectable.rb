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

# Add +facebook_connectable+ to default serializers and strategies.
#
Devise.setup do |config|
  config.warden do |manager|
    manager.default_strategies.unshift :facebook_connectable
    manager.default_serializers.unshift :facebook_connectable
  end
end