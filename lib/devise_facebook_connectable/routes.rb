ActionController::Routing::RouteSet::Mapper.class_eval do
  protected
    alias :facebook_connectable :authenticatable
end