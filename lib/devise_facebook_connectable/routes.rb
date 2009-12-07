# encoding: utf-8

ActionController::Routing::RouteSet::Mapper.class_eval do

  protected

    alias :facebook_connectable :authenticatable

end