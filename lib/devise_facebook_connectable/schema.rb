# encoding: utf-8
require 'devise_facebook_connectable/model'

module Devise
  module FacebookConnectable
    module Schema

      # Creates facebook_uid and facebook_session_key (for Facebook Connect authentication/management).
      #
      def facebook_connectable
        apply_schema ::Devise.facebook_uid_field, Integer, :limit => 8   # BIGINT unsigned / 64-bit int
        # apply_schema ::Devise.facebook_uid_field, String
        apply_schema ::Devise.facebook_session_key_field, String
      end

    end
  end
end

Devise::Schema.module_eval do
  include ::Devise::FacebookConnectable::Schema
end
