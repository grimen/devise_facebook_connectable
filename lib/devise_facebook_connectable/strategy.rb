# encoding: utf-8

module Devise
  module Strategies

    # Default strategy for signing in a user using Facebook Connect (a Facebook account).
    # Redirects to sign_in page if it's not authenticated
    #
    class FacebookConnectable < ::Warden::Strategies::Base

      include ::Devise::Strategies::Base

      # Without a Facebook session authentication cannot proceed.
      #
      def valid?
        session[:facebook_session].present?
      end

      # Authenticate user with Facebook Connect.
      #
      def authenticate!
        begin
          facebook_session = session[:facebook_session]
          user = mapping.to.facebook_connect(:uid => facebook_session.user.uid)

          if user.present?
            success!(user)
          else
            if mapping.to.facebook_skip_create?
              fail!(:facebook_invalid)
            else
              user = mapping.to.new do |u|
                u.store_facebook_credentials!(
                    :session_key => facebook_session.session_key,
                    :uid => facebook_session.user.uid,
                    :email => facebook_session.user.proxied_email
                  )
                u.before_connect(facebook_session)
              end

              begin
                user.save_with_validation(false)
                success!(user)
              rescue
                fail!(:facebook_invalid)
              end
            end
          end
        rescue ::Facebooker::Session::SessionExpired
          # TODO: Should maybe be handled?
          fail!(:facebook_session_expired)
        end
      end

    end
  end
end

Warden::Strategies.add(:facebook_connectable, Devise::Strategies::FacebookConnectable)
