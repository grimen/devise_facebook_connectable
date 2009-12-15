# encoding: utf-8

ActionController::Routing::RouteSet::Mapper.class_eval do

  protected

    # Setup routes for +FacebookSessionsController+.
    #
    alias :facebook_connectable :authenticatable

end