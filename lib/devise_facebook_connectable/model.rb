# encoding: utf-8
require 'devise'
require 'devise_facebook_connectable/strategy'

Devise::Models.module_eval do
    
    # Facebook Connectable Module, responsible for validating authenticity of a 
    # user and storing credentials while signing in using their Facebook account.
    #
    # Configuration:
    #
    # You can overwrite configuration values by setting in globally in Devise,
    # using devise method or overwriting the respective instance method.
    #
    #   facebook_uid_field: Defines the name of the Facebook user UID database attribute/column.
    #
    #   facebook_session_key_field: Defines the name of the Facebook session key database attribute/column.
    #
    #   facebook_skip_create: Speifies if account should automatically be created upon connect
    #                         if not already exists.
    #
    # Examples:
    #
    #    User.facebook_connect('123456789')             # returns authenticated user or nil
    #    User.find(1).facebook_connected?('123456789')  # returns true/false
    #
    module FacebookConnectable

      DEFAULT_FACEBOOK_UID_FIELD = :facebook_uid
      DEFAULT_FACEBOOK_SESSION_KEY_FIELD = :facebook_session_key
      
      def self.included(base)
        base.class_eval do
          extend ClassMethods

          #cattr_accessor :facebook_uid_field, :facebook_session_key_field, :facebook_skip_create
          #attr_protected @@facebook_uid_field, @@facebook_session_key_field, @@facebook_skip_create
          alias :facebook_skip_create? :facebook_skip_create
        end
      end

      # Store Facebook Connect account/session credentials.
      #
      def store_facebook_credentials!(attributes = {})
        self.send(:"#{self.class.facebook_uid_field}=", attributes[:uid])
        self.send(:"#{self.class.facebook_session_key_field}=", attributes[:session_key])
      end

      # Checks if Facebook Connected.
      #
      def facebook_connected?
        self.send(:"#{self.class.facebook_uid_field}").present?
      end
      alias :is_facebook_connected? :facebook_connected?

      # Hook that gets called before connect (each time). Useful for
      # fetching additional user info (etc.) from Facebook.
      #
      def before_facebook_connect(facebook_session)
        # Default: Nothing.
      end
      alias :before_connect :before_facebook_connect
      
      module ClassMethods

        # Specifies the name of the database column name used for storing
        # the user Facebook UID.
        #
        def facebook_uid_field
          @@facebook_uid_field || DEFAULT_FACEBOOK_UID_FIELD
        end

        # Specifies the name of the database column name used for storing
        # the user Facebook session key.
        #
        def facebook_session_key_field
          @@facebook_session_key_field || DEFAULT_FACEBOOK_SESSION_KEY_FIELD
        end

        # Authenticate using a Facebook UID.
        #
        def facebook_connect(attributes = {})
          return unless attributes[:facebook_uid].present?
          self.find_for_facebook_connect(attributes[:facebook_uid])
        end

        protected

          def find_for_facebook_connect(facebook_uid)
            self.find_by_facebook_uid(facebook_uid)
          end

          def valid_for_facebook_connect(resource, attributes)
            true
          end

        ::Devise::Models.config(self, :facebook_uid_field, :facebook_session_key_field, :facebook_skip_create)

      end

    end
end