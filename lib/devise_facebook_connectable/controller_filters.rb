# encoding: utf-8
require 'facebooker'

module Devise
  module FacebookConnectable
    module Controllers
      module Filters

        def self.included(klass)
          klass.class_eval do
            before_filter :expired_session_hack
            before_filter :set_facebook_session
            rescue_from ::Facebooker::Session::SessionExpired, :with => :facebook_session_expired

            helper_method :facebook_session

            # Required sprinkle of magic to avoid +Facebooker::Session::ExpiredSession+.
            #
            def expired_session_hack
              clear_facebook_session_information
            end

            # Handle expired Facebook sessions automatically.
            #
            def facebook_session_expired
              reset_session
              redirect_to root_url
            end

          end
        end

      end
    end
  end
end

ActionController::Base.send :include, Devise::FacebookConnectable::Controllers::Filters
