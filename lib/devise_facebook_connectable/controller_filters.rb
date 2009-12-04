module Devise
  module Controllers
    module Filters

      def self.included(klass)
        klass.class_eval do
          # before_filter :set_facebook_session
          helper_method :facebook_session
        end
      end

    end
  end
end