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
    s1 = e1.insertSource('src1');
    s1_1 = s1.insertSource('src1_1');
    s1_1.insertSource('src1_1_1');
    s2 = e1.insertSource('src2');
    s2_1 = s2.insertSource('src2_1');
    s2_1.insertSource('src2_1_1');
    g1 = e1.insertEpochGroup(s1, 'grp1', t, t);
    g1.insertEpochGroup(s1_1, 'grp1_1', t, t);
    b1 = g1.insertEpochBlock('protocol.test1', [], t, t);
    b1.insertEpoch(t, t);
    g2 = e1.insertEpochGroup(s2, 'grp2', t, t);
    g2.insertEpochGroup(s2_1, 'grp2_1', t, t);
    p1.insertExperiment('exp2', t, t);
    
    p2 = context.insertProject('second', 'another one for testing', t);
    p2.insertExperiment('exp3', t, t);
    p2.insertExperiment('exp4', t, t);
    p2.addExperiment(e1);
end