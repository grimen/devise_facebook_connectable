require 'devise/strategies/facebook_connectable'

module Devise
  module Models
    module FacebookConnectable

      DEFAULT_FACEBOOK_UID_FIELD = :facebook_uid
      DEFAULT_FACEBOOK_SESSION_KEY_FIELD = :facebook_session_key
      
      def self.included(base)
        base.class_eval do
          extend ClassMethods

          cattr_accessor :facebook_uid_field, :facebook_session_key_field, :facebook_skip_create
          attr_protected @@facebook_uid_field, @@facebook_session_key_field, @@facebook_skip_create
          alias :facebook_skip_create? :facebook_skip_create
        end
      end

      # Store Facebook Connect account/session credentials.
      #
      def store_credentials!(attributes = {})
        self.send(:"#{self.class.facebook_uid_field}=", attributes[:uid])
        self.send(:"#{self.class.facebook_session_key_field}=", attributes[:session_key])
      end

      # Hook that gets called before connect (each time). Useful for
      # fetching additional user info (etc.) from Facebook.
      #
      def before_connect(facebook_session)
        # Default: Nothing.
      end

      module ClassMethods

        def facebook_uid_field
          @@facebook_uid_field || DEFAULT_FACEBOOK_UID_FIELD
        end

        def facebook_session_key_field
          @@facebook_session_key_field || DEFAULT_FACEBOOK_SESSION_KEY_FIELD
        end

        # Authenticate using a Facebook UID.
        #
        def authenticate(attributes = {})
          return unless attributes[:facebook_uid].present?
          self.find_for_authentication(attributes[:facebook_uid])
        end

        protected

          def find_for_authentication(facebook_uid)
            self.find_by_facebook_uid(facebook_uid) rescue nil
          end

          def valid_for_authentication(resource, attributes)
            true
          end

      end

    end
  end
end