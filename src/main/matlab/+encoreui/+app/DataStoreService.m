classdef DataStoreService < handle

    events (NotifyAccess = private)
        AddedDataStore
    end

    properties (Access = private)
        session
    end

    methods

        function obj = DataStoreService(session)
            obj.session = session;
        end

        function s = addDataStore(obj, url, user, password)
            s = encore.core.DataStore(url);
            notify(obj, 'AddedDataStore', encoreui.app.AppEventData(s));
        end

    end

end
