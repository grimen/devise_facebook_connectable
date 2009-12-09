# encoding: utf-8
require 'facebooker'

module Devise
  module FacebookConnectable
    module Controllers
      module Filters

        def self.included(klass)
          klass.class_eval do
            before_filter :set_facebook_session
            helper_method :facebook_session # session[:facebook_session]
            rescue_from ::Facebooker::Session::SessionExpired, :with => :facebook_session_expired

            # Handle expired Facebook sessions automatically.
            #
            def facebook_session_expired
              clear_fb_cookies!
              clear_facebook_session_information
              redirect_to request.request_uri #root_url # TODO: Maybe a bad assumption? Maybe just re-load current page?
            end
          end
        end

      end
    end
  end
end

ActionController::Base.send :include, Devise::FacebookConnectable::Controllers::Filters