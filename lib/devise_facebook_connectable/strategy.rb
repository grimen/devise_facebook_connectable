# encoding: utf-8
require 'devise/strategies/base'
# require 'facebooker/session'

module Devise
  module FacebookConnectable

    # Default strategy for signing in a user using Facebook Connect (a Facebook account).
    # Redirects to sign_in page if it's not authenticated
    #
    class Strategy < ::Warden::Strategies::Base

      include ::Devise::Strategies::Base

      # Without a Facebook session authentication cannot proceed.
      #
      def valid?
        ::Facebooker::Session.current.present?
      end

      # Authenticate user with Facebook Connect.
      #
      def authenticate!
        klass = mapping.to
        begin
          facebook_session = ::Facebooker::Session.current # session[:facebook_session]
          facebook_user = facebook_session.user

          user = klass.facebook_connect(:uid => facebook_user.uid)

          if user.present?
            success!(user)
          else
            if klass.facebook_auto_create_account?
              user = returning(klass.new) do |u|
                u.store_facebook_credentials!(
                    :session_key => facebook_session.session_key,
                    :uid => facebook_user.uid
                  )
                u.on_before_facebook_connect(facebook_session)
              end

              begin
                user.save_with_validation(false)
                success!(user)
              rescue
                fail!(:invalid)
              end
            else
              fail!(:invalid)
            end
          end
        # NOTE: Handled in the controller.
        rescue # ::Facebooker::Session::SessionExpired
          fail!(:timeout)
        end
      end

    end
  end
end

Warden::Strategies.add(:facebook_connectable, Devise::FacebookConnectable::Strategy)
