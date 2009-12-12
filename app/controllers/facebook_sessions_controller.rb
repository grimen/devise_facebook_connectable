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
      # already signed in: sign_in(resource_name)
      redirect_to fbc_after_sign_in_path_for(resource_name) || after_sign_in_path_for
    else
      set_flash_message :failure, warden.message || :invalid
      redirect_to fbc_after_sign_in_failure_path_for(resource_name) || after_sign_in_path_for
    end
  end

  # GET /resource/sign_out
  def destroy
    set_flash_message :success, :signed_out if signed_in?(resource_name)
    sign_out(resource_name)
    redirect_to fbc_after_sign_out_path_for(resource_name) || after_sign_out_path_for
  end

  protected

    # TODO: Make these config:able.

    # Default redirect url: Sign in success.
    #
    def fbc_after_sign_in_path_for(resource_name)
      root_path
    end

    # Default redirect url: Sign in failure.
    #
    def fbc_after_sign_in_failure_path_for(resource_name)
      root_path
    end

    # Default redirect url: Sign out.
    #
    def fbc_after_sign_out_path_for(resource_name)
      root_path
    end

end
