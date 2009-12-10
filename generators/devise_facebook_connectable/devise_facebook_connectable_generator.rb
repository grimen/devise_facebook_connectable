# encoding: utf-8

class DeviseFacebookConnectableGenerator < Rails::Generator::Base

  default_options :api_key => "YOUR_APP_API_KEY",
                  :secret_key => "YOUR_APP_SECRET_KEY"

  def manifest
    record do |m|
      m.dependency 'xd_receiver', [], options.merge(:collision => :skip)
      m.template 'facebooker.yml', File.join(*%w[config facebooker.yml])
      m.template 'devise.facebook_connectable.js', File.join(*%w[public javascripts devise.facebook_connectable.js])
    end
  end

  protected

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'

      opt.on('--api API_KEY', "Facebook Application API key.") do |v|
        options[:api_key] = v if v.present?
      end

      opt.on('--secret SECRET_KEY', "Facebook Application Secret key.") do |v|
        options[:secret_key] = v if v.present?
      end
    end

    def banner
      "Usage: #{$0} devise_facebook_connectable [--api API_KEY] [--secret SECRET_KEY]"
    end

end