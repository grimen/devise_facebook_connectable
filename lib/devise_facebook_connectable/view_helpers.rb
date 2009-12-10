# encoding: utf-8
require 'devise/mapping'

# Facebook Connect view helpers, i.e. connect/login/logout links, etc.
#
# Dependencies:
#
#   +devise.facebook_connectable.js+  (is generated with the generator)
#
module Devise
  module FacebookConnectable
    module Helpers

      # References:
      #
      #   * http://facebooker.rubyforge.org/
      #   * http://wiki.developers.facebook.com/index.php/Connect/Authorization_Websites
      #   * http://developers.facebook.com/docs/?u=facebook.jslib.FB.Connect
      #

      # Known issues:
      #
      #   * autologoutlink -  There's no onlogout callback - only onlogin, so it's not straightforward
      #                       to trigger submit on the logout form to destroy the Warden session.
      #                       Best solution now is either to hook the even manually on click,
      #                       or use regular link like propsed here:
      #                         
      #                         http://forum.developers.facebook.com/viewtopic.php?pid=121283
      #

      # Make the Facebook Connect strings localized with current locale
      # by default. Just for convenience.
      #
      def localized_fb_connect_javascript_tag(options = {})
        fb_connect_javascript_tag(options.reverse_merge(:lang => ::I18n.locale))
      end

      # Convenient connect/login/logout method. See below.
      #
      def facebook_link(options = {})
        unless signed_in?(options[:for])
          facebook_login_or_connect_link(options)
        else
          facebook_logout_link(options)
        end
      end

      # Agnostic Facebook Connect login/connect button/link.
      #
      # Case 1: If Facebook account already connected to the app/site, this is same as
      # a traditional "account login" but with the Facebook dialog unless already
      # logged in to Facebook.
      # 
      # Case 2: If account is not connected to the app/site already;
      # then this is the same as a traditional "create account".
      #
      def facebook_login_or_connect_link(options = {})
        resource = options.delete(:for)
        options.reverse_merge!(
            :label => ::I18n.t(:facebook_login, :scope => [:devise, :sessions]),
            :size => :large,
            :length => :long,
            :background => :white,
            :button => true,
            :autologoutlink => false
          )

        # It seems Devise using :get method for session destroy. Not really RESTful?
        # options.merge!(:method => :delete) if options[:autologoutlink] && signed_in?(options[:for])

        content_tag(:span, :class => 'fb_connect_login_link') do
          facebook_connect_form(resource, options.slice(:method)) <<
          if options[:button]
            fb_login_button('devise.facebook_connectable.login();', options)
          else
            fb_logout_link(options[:label], 'devise.facebook_connectable.login_with_callback();')
          end
        end
      end
      alias :facebook_login_link :facebook_login_or_connect_link
      alias :facebook_connect_link :facebook_login_or_connect_link

      # Agnostic Facebook Connect logout button/link. Logs out the current
      # user from both the app/site and Facebook main site (for security reasons).
      #
      def facebook_logout_link(options = {})
        options.reverse_merge!(
            :label => ::I18n.t(:facebook_logout, :scope => [:devise, :sessions]),
            :size => :large,
            :length => :long,
            :background => :white,
            :button => false
          )

        content_tag(:span, :class => 'fb_connect_logout_link') do
          facebook_connect_form(options.delete(:for), :logout => true, :method => :get) <<
          if options[:button]
            fb_login_button('devise.facebook_connectable.logout();', options.merge(:autologoutlink => true))
          else
            fb_logout_link(options[:label], destroy_session_path(:user))
          end
        end
      end

      # Agnostic Facebook Connect disconnect button/link.
      # Disconnects, i.e. deletes, user account. Identical as "Delete my account",
      # but for Facebook Connect (which "un-installs" the app/site for the current user).
      #
      # References:
      #
      #   * http://wiki.developers.facebook.com/index.php/Auth.revokeAuthorization
      #
      def facebook_disconnect_link(options = {})
        raise "facebook_disconnect_link: Not implemented yet."
        # TODO: 
        # options.reverse_merge!(
        #     :label => ::I18n.t(:facebook_logout, :scope => [:devise, :sessions]),
        #   )
        # content_tag(:div, :class => 'fb_connect_disconnect_link') do
        #   link_to_function(options[:label], 'devise.facebook_connectable.disconnect_with_callback();')
        # end
      end

      protected

        # Generate agnostic hidden login/logout form for Facebook Connect.
        #
        def facebook_connect_form(for_resource, options = {})
          logout_form = options.delete(:logout) || (options[:method] == :delete)
          options.reverse_merge!(
              :id => (logout_form ? 'fb_connect_logout_form' : 'fb_connect_login_form'),
              :style => 'display:none;'
            )
          resource = ::Devise::Mapping.find_by_path(request.path).to rescue for_resource
          url = logout_form ? destroy_session_path(resource) : session_path(resource)
          form_for(resource, :url => url, :html => options) { |f| }
        end

    end
  end
end

::ActionView::Base.send :include, ::Devise::FacebookConnectable::Helpers
