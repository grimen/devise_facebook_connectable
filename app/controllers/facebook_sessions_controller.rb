# encoding: utf-8

# Controller for managing Facebook (Connect) sessions.
#
class FacebookSessionsController < ApplicationController
  include Devise::Controllers::Helpers

  before_filter :require_no_authentication, :only => [:create]

  # POST /resource/sign_in
  def create
    if authenticate(resource_name)
      set_flash_message :success, :signed_in
      sign_in_and_redirect(resource_name)
    else
      set_flash_message :failure, warden.message || :invalid
      # TODO: Make this URL config:able, e.g. "confirm imported info", etc. (proc or string)
      redirect_to root_url
    end
  end

  # GET /resource/sign_out
  def destroy
    set_flash_message :success, :signed_out if signed_in?(resource_name)
    # TODO: Make this URL config:able. See above.
    sign_out_and_redirect(resource_name)
  end

end
