# encoding: utf-8

module Devise
  module Helpers
    module FacebookConnectable

      # Agnostic Facebook Connect login/connect button or link.
      #
      def facebook_connect_link(options = {})
        options.reverse_merge!(
            :label => ::I18n.t(:facebook_login, :scope => [:devise]),
            :size => :large,
            :length => :long,
            :autologoutlink => false,
            :background => :white,
            :button => true
          )

        link_html = facebook_connect_form(options.delete(:to))
        link_html += if options[:button]
          fb_login_button('fb_connect_login();', options)
        else
          link_to_function(options[:label], 'fb_connect_custom_login();')
        end

        #content_tag(:span, link_html, :class => 'fb_connect_login_link')
        link_html
      end
      alias :facebook_login_link :facebook_connect_link

      # Agnostic Facebook Connect logout button or link.
      #
      def facebook_logout_link(options ={})
        options.reverse_merge!(
            :label => ::I18n.t(:facebook_logout, :scope => [:devise]),
            :size => :small,
            :length => :long,
            :background => :white,
            :button => true
          )

        link_html = facebook_connect_form(options.delete(:to).merge(:method => :delete))
        link_html += if options[:button]
          fb_login_button('fb_connect_logout();', options)
        else
          link_to_function(options[:label], 'fb_connect_custom_logout();')
        end

        content_tag(:span, link_html, :class => 'fb_connect_logout_link')
      end

      protected

        # Generate agnostic hidden login/logout form for Facebook Connect.
        #
        def facebook_connect_form(to, html_options = {})
          html_options.reverse_merge!(
              :id => (html_options[:method] == :delete ? 'fb_connect_logout_form' : 'fb_connect_login_form'),
              :style => 'display:none;'
            )
          # FIXME: Fix form object and URL to generic.
          mapping_to = ::Devise::Mapping.find_by_path(request.path).to rescue to
          form_for(mapping_to, :url => session_path(mapping_to), :html => html_options) { |f| }
        end

    end
  end
end

::ActionView::Base.send :include, ::Devise::Helpers::FacebookConnectable
