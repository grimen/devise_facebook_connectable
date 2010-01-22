# encoding: utf-8
require 'facebooker/session'

module Devise #:nodoc:
  module FacebookConnectable #:nodoc:
    module Controllers #:nodoc:

      # Controller filters (extensions) needed for Facebook Connect.
      #
      module Filters

        # == References
        #
        # For more info about the available Facebooker controller methods:
        #
        #   * http://github.com/mmangino/facebooker/blob/master/lib/facebooker/rails/controller.rb
        #

        def self.included(base) #:nodoc:
          base.class_eval do
            before_filter :expired_session_hack
            before_filter :set_facebook_session

            rescue_from ::Facebooker::Session::SessionExpired, :with => :facebook_session_expired
            rescue_from ::ActionController::InvalidAuthenticityToken, :with => :invalid_authenticity_token

            helper_method :facebook_session

            # Required sprinkle of magic to avoid +Facebooker::Session::ExpiredSession+.
            #
            def expired_session_hack
              clear_facebook_session_information
            rescue
              if RUBY_VERSION >= '1.9' && RAILS_GEM_VERSION == '2.3.4'
                # Rails 2.3.4 on Ruby 1.9 issue. Should not happen in Rails 2.3.5+
                # See: https://rails.lighthouseapp.com/projects/8994/tickets/3144
                raise "Error caused by a known session handling bug in Rails 2.3.4 on Ruby 1.9." <<
                  " Please try to install Rails 2.3.5+ to be on the safe side."
              end
            end

            # Handle expired Facebook sessions automatically.
            #
            def facebook_session_expired
              reset_session
              set_flash_message :failure, :facebook_timeout
              render_with_scope :new, :controller => :sessions
            end

            # Handle expired Facebook sessions automatically.
            #
            def invalid_authenticity_token
              set_now_flash_message :failure, :facebook_authenticity_token
              render_with_scope :new, :controller => :sessions
            end

          end
        end

      end
    end
  end
end

ActionController::Base.send :include, Devise::FacebookConnectable::Controllers::Filters
