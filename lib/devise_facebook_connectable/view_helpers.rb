# encoding: utf-8
require 'devise/mapping'
require 'facebooker/rails/helpers'

module Devise #:nodoc:
  module FacebookConnectable #:nodoc:

    # Facebook Connect view helpers, i.e. sign in/out (connect) links, etc.
    #
    # == Dependencies:
    #
    #   * devise.facebook_connectable.js  (is generated with the generator)
    #
    module Helpers

      # == References:
      #
      #   * http://facebooker.rubyforge.org/
      #   * http://wiki.developers.facebook.com/index.php/Connect/Authorization_Websites
      #   * http://developers.facebook.com/docs/?u=facebook.jslib.FB.Connect
      #

      # == Known issues:
      #
      #   * *autologoutlink* -  There's no onlogout callback - only onlogin, so it's not straightforward
      #                         to trigger submit on the sign out form to destroy the Warden session.
      #                         Best solution now is either to hook the even manually on click,
      #                         or use regular link like propsed here:
      #
      #                         http://forum.developers.facebook.com/viewtopic.php?pid=121283
      #

      # Convenient sign in/out (connect) method. See below.
      #
      def facebook_link(*args)
        scope = auto_detect_scope(*args)
        unless signed_in?(scope)
          facebook_sign_in_link(*args)
        else
          facebook_sign_out_link(*args)
        end
      end

      # Agnostic Facebook Connect sign in/out (connect) button/link.
      #
      # *Case 1:* If Facebook account already connected to the app/site, this is same as
      # a traditional "account sign in" but with the Facebook dialog unless already
      # logged in to Facebook.
      #
      # *Case 2:* If account is not connected to the app/site already;
      # then this is the same as a traditional "create account".
      #
      def facebook_sign_in_link(*args)
        scope = auto_detect_scope(*args)
        options = args.extract_options!
        options.except!(:scope, :for)
        options.reverse_merge!(
            :label => ::I18n.t(:sign_in, :scope => [:devise, :sessions, :facebook_actions]),
            :size => :large,
            :length => :long,
            :background => :white,
            :button => true,
            :autologoutlink => false
          )
        options.merge!(:sign_out => true) if options[:autologoutlink] && signed_in?(scope)

        content_tag(:div, :class => 'facebook_connect_link sign_in') do
          facebook_connect_form(scope, options.slice(:method)) <<
          if options[:button]
            fb_login_button('devise.facebook_connectable.sign_in();', options)
          else
            fb_logout_link(options[:label], 'devise.facebook_connectable.sign_in_with_callback();')
          end
        end
      end
      alias :facebook_connect_link :facebook_sign_in_link

      # Agnostic Facebook Connect sign_out button/link. Logs out the current
      # user from both the app/site and Facebook main site (for security reasons).
      #
      def facebook_sign_out_link(*args)
        scope = auto_detect_scope(*args)
        options = args.extract_options!
        options.except!(:scope, :for)
        options.reverse_merge!(
            :label => ::I18n.t(:sign_out, :scope => [:devise, :sessions, :facebook_actions]),
            :size => :large,
            :length => :long,
            :background => :white,
            :button => false
          )

        content_tag(:div, :class => 'facebook_connect_link sign_out') do
          facebook_connect_form(scope, :sign_out => true, :method => :get) <<
          if options[:button]
            fb_login_button('devise.facebook_connectable.sign_out();', options.merge(:autologoutlink => true))
          else
            fb_logout_link(options[:label], destroy_session_path(:user))
          end
        end
      end

      # TODO: Agnostic Facebook Connect disconnect button/link.
      # Disconnects, i.e. deletes, user account. Identical as "Delete my account",
      # but for Facebook Connect (which "un-installs" the app/site for the current user).
      #
      # == References:
      #
      #   * http://wiki.developers.facebook.com/index.php/Auth.revokeAuthorization
      #
      def facebook_disconnect_link(*args)
        raise "facebook_disconnect_link: Not implemented yet."
        # TODO:
        # options.reverse_merge!(
        #     :label => ::I18n.t(:facebook_disconnect, :scope => [:devise, :sessions, :actions]),
        #   )
        # content_tag(:div, :class => 'fb_connect_disconnect_link') do
        #   link_to_function(options[:label], 'devise.facebook_connectable.disconnect_with_callback();')
        # end
      end

      protected

        # Auto-detect Devise scope using +Devise.default_scope+.
        # Used to make the link-helpers smart if - like in most cases -
        # only one devise scope will be used, e.g. "user" or "account".
        #
        def auto_detect_scope(*args)
          options = args.extract_options!

          if options.key?(:for)
            options[:scope] = options[:for]
            ::ActiveSupport::Deprecation.warn("DEPRECATION: " <<
              "Devise scope :for option is deprecated. " <<
              "Use: facebook_*_link(:some_scope), or facebook_*_link(:scope => :some_scope)")
          end

          scope = args.detect { |arg| arg.is_a?(Symbol) } || options[:scope] || ::Devise.default_scope
          mapping = ::Devise.mappings[scope]

          if mapping.for.include?(:facebook_connectable)
            scope
          else
            error_message =
              "%s" <<
              " Did you forget to devise facebook_connect in your model? Like this: devise :facebook_connectable." <<
              " You can also specify scope explicitly, e.g.: facebook_*link :for => :customer."
            error_message %=
              if scope.present?
                "#{scope.inspect} is not a valid facebook_connectable devise scope. " <<
                "Loaded modules for this scope: #{mapping.for.inspect}."
              else
                "Could not auto-detect any facebook_connectable devise scope."
              end
            raise error_message
          end
        end

        # Generate agnostic hidden sign in/out (connect) form for Facebook Connect.
        #
        def facebook_connect_form(scope, options = {})
          sign_out_form = options.delete(:sign_out)
          options.reverse_merge!(
              :id => (sign_out_form ? 'fb_connect_sign_out_form' : 'fb_connect_sign_in_form'),
              :style => 'display:none;'
            )
          scope = ::Devise::Mapping.find_by_path(request.path).name rescue scope
          url = sign_out_form ? destroy_session_path(scope) : session_path(scope)

          form_for(scope, :url => url, :html => options) { |f| }
        end

    end
  end
end

::ActionView::Base.send :include, Devise::FacebookConnectable::Helpers
