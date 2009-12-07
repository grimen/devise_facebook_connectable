# encoding: utf-8
require 'devise_facebook_connectable/strategy'
require 'devise_facebook_connectable/serializer'

# FIXME: Don't know why I had to do this. I'm missing something. For some reason
# Devise::Models gets unloaded when I do it the classic way. =S
#
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
    #    User.facebook_connect(:uid => '123456789')     # returns authenticated user or nil
    #    User.find(1).facebook_connected?               # returns true/false
    #
    module FacebookConnectable

      DEFAULT_FACEBOOK_UID_FIELD = :facebook_uid
      DEFAULT_FACEBOOK_SESSION_KEY_FIELD = :facebook_session_key

      def self.included(base)
        base.class_eval do
          extend ClassMethods

          cattr_accessor :facebook_uid_field, :facebook_session_key_field, :facebook_skip_create
          attr_protected @@facebook_uid_field, @@facebook_session_key_field, @@facebook_skip_create
        end
      end

      # Store Facebook Connect account/session credentials.
      #
      def store_facebook_credentials!(attributes = {})
        # FIXME: Don't work...nil for some reason.
        # self.send(:"#{self.class.facebook_uid_field}=", attributes[:uid])
        # self.send(:"#{self.class.facebook_session_key_field}=", attributes[:session_key])
        
        self.send(:"#{DEFAULT_FACEBOOK_UID_FIELD}=", attributes[:uid])
        self.send(:"#{DEFAULT_FACEBOOK_SESSION_KEY_FIELD}=", attributes[:session_key])
        
        # Only populate +email+ field if it's available (say, if +authenticable+ module is used).
        self.email = attributes[:email] if self.respond_to?(:email)
        
        # Lazy hack: These database fields are required if +authenticable+/+confirmable+
        # module(s) is used.
        self.password_salt = '' if self.respond_to?(:password_salt)
        self.encrypted_password = '' if self.respond_to?(:encrypted_password)
        self.confirmed_at = ::Time.now if self.respond_to?(:confirmed_at)
      end

      # Checks if Facebook Connect:ed.
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

      def store_session(using_session_key)
        if self.session_key != using_session_key
          self.update_attribute(:facebook_session_key, using_session_key)
        end
      end

      def facebook_session
        @facebook_session ||=
          returning(::Facebooker::Session.create) do |new_session|
            new_session.secure_with!(self.facebook_session_key, self.facebook_uid, 1.hour.from_now)
            ::Facebooker::Session.current = new_session
          end
      end

      module ClassMethods

        # Alias don't work for some reason, so...a more Ruby-ish alias
        # for +facebook_skip_create+.
        #
        def facebook_skip_create?
          self.facebook_skip_create
        end

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
          if attributes[:uid].present?
            self.find_for_facebook_connect(attributes[:uid])
          end
        end

        # COPY-PASTE from Devise "authenticable": Hook to serialize user into session. Overwrite if you want.
        #
        def serialize_into_session(record)
          [record.class, record.id]
        end

        # COPY-PASTE from Devise "authenticable": Hook to serialize user from session. Overwrite if you want.
        #
        def serialize_from_session(keys)
          klass, id = keys
          raise "#{self} cannot serialize from #{klass} session since it's not its ancestors" unless klass <= self
          klass.find(:first, :conditions => { :id => id })
        end

        protected

          def find_for_facebook_connect(uid)
            self.find_by_facebook_uid(uid)
          end

          def valid_for_facebook_connect(resource, attributes)
            true
          end

        ::Devise::Models.config(self, :facebook_uid_field, :facebook_session_key_field, :facebook_skip_create)

      end

    end
end