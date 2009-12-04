require 'warden'
require 'facebooker'

module Devise
  module Strategies
    class FacebookConnectable < ::Warden::Strategies::Base

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
          user = mapping.to.authenticate(facebook_session.user.uid)

          if user.present?
            success!(user)
          else
            if mapping.to.facebook_skip_create?
              fail!(:invalid)
            else
              user = mapping.to.new do |u|
                u.store_credentials!(:uid => facebook_session.user.uid, :session_key => facebook_session.session_key)
                u.before_connect(facebook_session)
              end

              begin
                user.save_with_validation!(false)
                success!(user)
              rescue ::RecordInvalid
                fail!(:invalid)
              end
            end
          end
        rescue ::Facebooker::Session::SessionExpired
          fail!(:session_expired)
        end
      end

    end
  end
end

Warden::Strategies.add(:facebook_connectable, Devise::Strategies::FacebookConnectable)
