classdef DataSourceService < handle
    
    events (NotifyAccess = private)
        AddedDataSource
    end
    
    properties (Access = private)
        session
    end
    
    methods
        
        function obj = DataSourceService(session)
            obj.session = session;
        end
        
        function s = addDataSource(obj, url, user, password)
            s = encore.core.DataSource(url);
            notify(obj, 'AddedDataSource', encoreui.app.AppEventData(s));
        end
        
    end
    
end

