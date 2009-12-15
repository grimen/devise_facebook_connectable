# encoding: utf-8
require 'devise/models'
# require 'facebooker/session'
require 'devise_facebook_connectable/strategy'
require 'devise_facebook_connectable/serializer'

module Devise #:nodoc:
  # module FacebookConnectable #:nodoc:
    module Models #:nodoc:

      # Facebook Connectable Module, responsible for validating authenticity of a 
      # user and storing credentials while signing in using their Facebook account.
      #
      # == Configuration:
      #
      # You can overwrite configuration values by setting in globally in Devise (+Devise.setup+),
      # using devise method, or overwriting the respective instance method.
      #
      # +facebook_uid_field+ - Defines the name of the Facebook user UID database attribute/column.
      #
      # +facebook_session_key_field+ - Defines the name of the Facebook session key database attribute/column.
      #
      # +facebook_auto_create_account+ - Speifies if account should automatically be created upon connect
      #                                 if not already exists.
      #
      # == Examples:
      #
      #    User.facebook_connect(:uid => '123456789')     # returns authenticated user or nil
      #    User.find(1).facebook_connected?               # returns true/false
      #
      module FacebookConnectable

        def self.included(base) #:nodoc:
          base.class_eval do
            extend ClassMethods
            extend ::Devise::Models::SessionSerializer
          end
        end

        # Store Facebook Connect account/session credentials.
        #
        def store_facebook_credentials!(attributes = {})
          self.send(:"#{self.class.facebook_uid_field}=", attributes[:uid])
          self.send(:"#{self.class.facebook_session_key_field}=", attributes[:session_key])

          # Only populate +email+ field if it's available (say, if +authenticable+ module is used).
          self.email = attributes[:email] || '' if self.respond_to?(:email)

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

        # Hook that gets called *before* connect (each time). Useful for
        # fetching additional user info (etc.) from Facebook.
        #
        # Default: Do nothing.
        #
        # == Examples:
        #
        #   # Overridden in Facebook Connect:able model, e.g. "User".
        #   #
        #   def before_facebook_connect(fb_session)
        #     
        #     # Just fetch what we really need from Facebook...
        #     fb_session.user.populate(:locale, :current_location, :username, :name,
        #                               :first_name, :last_name, :birthday_date, :sex,
        #                               :city, :state, :country)
        #     
        #     self.locale             = my_fancy_locale_parser(fb_session.user.locale)
        #     "Stockholm" => "(GMT+01:00) Stockholm", "Never-Never-land" => "(GMT+00:00) UTC"
        #     self.time_zone          = fb_session.user.current_location.try(:city)
        #     self.country            = fb_session.user.current_location.try(:country)
        #     
        #     self.username           = fb_session.user.username
        #     
        #     self.profile.real_name  = fb_session.user.name
        #     self.profile.first_name = fb_session.user.first_name
        #     self.profile.last_name  = fb_session.user.last_name
        #     self.profile.birthdate  = fb_session.user.birthday_date.try(:to_date)
        #     self.profile.gender     = my_fancy_gender_parser(fb_session.user.sex)
        #     
        #     self.profile.city       = fb_session.user.hometown_location.try(:city)
        #     self.profile.zip_code   = fb_session.user.hometown_location.try(:state)
        #     self.profile.country    = fb_session.user.hometown_location.try(:country)
        #     
        #     # etc...
        #     
        #   end
        #
        # == For more info:
        #
        #   * http://facebooker.pjkh.com/user/populate
        #
        def on_before_facebook_connect(facebook_session)
          if self.respond_to?(:before_facebook_connect)
            self.send(:before_facebook_connect, facebook_session) rescue nil
          end
        end
        
        # Hook that gets called *after* connect (each time). Useful for
        # fetching additional user info (etc.) from Facebook.
        #
        # Default: Do nothing.
        #
        # == Example:
        #
        #   # Overridden in Facebook Connect:able model, e.g. "User".
        #   #
        #   def after_facebook_connect(fb_session)
        #     # See "on_before_facebook_connect" example.
        #   end
        #
        def on_after_facebook_connect(facebook_session)
          if self.respond_to?(:after_facebook_connect)
            self.send(:after_facebook_connect, facebook_session) rescue nil
          end
        end

        # Optional: Store session key.
        #
        def store_session(using_session_key)
          if self.session_key != using_session_key
            self.update_attribute(self.send(:"#{self.class.facebook_session_key_field}"), using_session_key)
          end
        end

        # Optional: Recreate Facebook session for this account/user.
        #
        def new_facebook_session
          returning(::Facebooker::Session.create) do |new_session|
            new_session.secure_with!(self.send(:"#{self.class.facebook_session_key_field}"),
                self.send(:"#{self.class.facebook_uid_field}"),
                1.hour.from_now
              )
            ::Facebooker::Session.current = new_session
          end
        end

        # Optional: See +new_facebook_session+.
        #
        def facebook_session(force = false)
          @facebook_session = self.new_facebook_session if force || @facebook_session.nil?
          @facebook_session
        end

        module ClassMethods

          # Configuration params accessible within +Devise.setup+ procedure (in initalizer).
          #
          # == Example:
          #
          #   Devise.setup do |config|
          #     config.facebook_uid_field = :facebook_uid
          #     config.facebook_session_key_field = :facebook_session_key
          #     config.facebook_auto_create_account = true
          #   end
          #
          ::Devise::Models.config(self,
              :facebook_uid_field,
              :facebook_session_key_field,
              :facebook_auto_create_account
            )

          # Alias don't work for some reason, so...a more Ruby-ish alias
          # for +facebook_auto_create_account+.
          #
          def facebook_auto_create_account?
            self.facebook_auto_create_account
          end

          # Authenticate using a Facebook UID.
          #
          def facebook_connect(attributes = {})
            if attributes[:uid].present?
              self.find_for_facebook_connect(attributes[:uid])
            end
          end

          protected

            # Find first record based on conditions given (Facebook UID).
            # Overwrite to add customized conditions, create a join, or maybe use a
            # namedscope to filter records while authenticating.
            #
            # == Example:
            #
            #   def self.find_for_facebook_connect(conditions = {})
            #     conditions[:active] = true
            #     self.find(:first, :conditions => conditions)
            #   end
            #
            def find_for_facebook_connect(uid)
              self.find_by_facebook_uid(uid)
            end

            # Contains the logic used in authentication. Overwritten by other devise modules.
            # In the Facebook Connect case; nothing fancy required.
            #
            def valid_for_facebook_connect(resource, attributes)
              true
            end

        end

      end
    end
  # end
end
