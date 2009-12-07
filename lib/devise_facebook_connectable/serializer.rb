# encoding: utf-8

module Devise
  module Serializers
    class FacebookConnectable < ::Warden::Serializers::Session
      include ::Devise::Serializers::Base
    end
  end
end

Warden::Serializers.add(:facebook_connectable, Devise::Serializers::FacebookConnectable)
