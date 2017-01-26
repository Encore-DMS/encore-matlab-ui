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

        function c = addDataStore(obj, host, user, password)
            coordinator = encore.core.Encore.connect(host, user, password);
            c = coordinator.getContext();
            % TODO: Remove me
            addTestData(c);
            notify(obj, 'AddedDataStore', encoreui.app.AppEventData(c));
        end

    end

end

function addTestData(context)
    t = datetime('now', 'TimeZone', 'local');
    
    p1 = context.insertProject('my first', 'for testing purposes', t, t);
    p1.insertExperiment('exp1', t, t);
    p1.insertExperiment('exp2', t, t);
    
    p2 = context.insertProject('second', 'another one for testing', t);
    p2.insertExperiment('exp3', t, t);
    p2.insertExperiment('exp4', t, t);
end