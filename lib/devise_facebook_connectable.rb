# encoding: utf-8
begin
  require 'facebooker'
rescue
  gem 'facebooker'
  require 'facebooker'
end

require 'devise_facebook_connectable/model'
require 'devise_facebook_connectable/strategy'
require 'devise_facebook_connectable/schema'
#require 'devise_facebook_connectable/controller_filters'
require 'devise_facebook_connectable/view_helpers'