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
        klass = mapping.to
        begin
          facebook_session = session[:facebook_session]
          facebook_user = facebook_session.user
          user = klass.facebook_connect(:uid => facebook_user.uid)

          if user.present?
            success!(user)
          else
            if klass.facebook_skip_create?
              fail!(:facebook_invalid)
            else
              user = returning(klass.new) do |u|
                u.store_facebook_credentials!(
                    :session_key => facebook_session.session_key,
                    :uid => facebook_user.uid,
                    :email => facebook_user.proxied_email
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
        # Now handled in the controller.
        # rescue ::Facebooker::Session::SessionExpired
          # fail!(:facebook_session_expired)
        end
      end

    end
  end
end

Warden::Strategies.add(:facebook_connectable, Devise::Strategies::FacebookConnectable)
