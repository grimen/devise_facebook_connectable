# encoding: utf-8

ActionController::Routing::RouteSet::Mapper.class_eval do

  protected

    # Setup routes for +FacebookSessionsController+.
    #
    def facebook_connectable(routes, mapping)
      routes.with_options(:controller => 'facebook_sessions', :name_prefix => nil) do |session|
        session.send(:"new_#{mapping.name}_session",     mapping.path_names[:sign_in],  :action => 'new',     :conditions => { :method => :get })
        session.send(:"#{mapping.name}_session",         mapping.path_names[:sign_in],  :action => 'create',  :conditions => { :method => :post })
        session.send(:"destroy_#{mapping.name}_session", mapping.path_names[:sign_out], :action => 'destroy', :conditions => { :method => :get })
      end
    end

end