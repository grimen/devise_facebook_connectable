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
#require 'devise_facebook_connectable/controller_filters'
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
      @@logger.send(level.to_sym, "[validatious-on-rails:]  #{level.to_s.upcase}  #{message}")
    end
    
  end
end