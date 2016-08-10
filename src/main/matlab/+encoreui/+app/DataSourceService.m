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
        
        function d = addDataSource(obj, url, user, password)
            d = encore.core.DataSource(url);
            notify(obj, 'AddedDataSource', encoreui.app.AppEventData(d));
        end
        
    end
    
end

