# encoding: utf-8

class DeviseFacebookConnectableGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.dependency 'xd_receiver', [], options.merge(:collision => :skip)
      m.template 'facebooker.yml', File.join(*%w[config facebooker.yml])
      m.template 'devise.facebook_connectable.js', File.join(*%w[public javascripts devise.facebook_connectable.js])
    end
  end

end