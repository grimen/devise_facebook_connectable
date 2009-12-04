module Devise
  module Schema

    # Creates facebook_uid and facebook_session_key (for Facebook Connect authentication/management).
    def facebook_connectable
      apply_schema :facebook_uid, String
      # or: apply_schema :facebook_uid, Integer, :limit => 8   # BIGINT unsigned / 64-bit int
      apply_schema :facebook_session_key, String
    end

  end
end