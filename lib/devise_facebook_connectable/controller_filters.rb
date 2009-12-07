# encoding: utf-8

module Devise
  module Controllers
    module Filters
      module FacebookConnectable

        def self.included(klass)
          klass.class_eval do
            before_filter :set_facebook_session
            helper_method :facebook_session # session[:facebook_session]
          end
        end

      end
    end
  end
end

# Devise::Controllers::Filters.send :include, Devise::Controllers::Filters::FacebookConnectable