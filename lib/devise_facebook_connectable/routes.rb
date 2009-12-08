# encoding: utf-8

ActionController::Routing::RouteSet::Mapper.class_eval do

  protected
    # Re-use "authenticatable"-stuff.
    alias :facebook_connectable :authenticatable

end