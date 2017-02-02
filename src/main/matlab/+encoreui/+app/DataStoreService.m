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

        function c = addDataStore(obj, host, username, password)
            c = encore.core.Encore.connect(host, username, password);
            % TODO: Remove me
            addTestData(c);
            notify(obj, 'AddedDataStore', encoreui.app.AppEventData(c));
        end
        
        function sendEntityToWorkspace(obj, entity) %#ok<INUSL>
            name = matlab.lang.makeValidName(entity.uuid);
            assignin('base', name, entity);
            evalin('base', ['disp(''' name ' = ' class(entity) ''')']);
        end

    end

end

function addTestData(coordinator)
    context = coordinator.getContext();

    t = datetime('now', 'TimeZone', 'local');
    
    p1 = context.insertProject('my first', 'for testing purposes', t, t);
    e1 = p1.insertExperiment('exp1', t, t);
    p1.insertExperiment('exp2', t, t);
    
    p2 = context.insertProject('second', 'another one for testing', t);
    p2.insertExperiment('exp3', t, t);
    p2.insertExperiment('exp4', t, t);
    p2.addExperiment(e1);
end