classdef ConfigurationService < handle
    
    properties (Access = private)
        session
    end
    
    methods
        
        function obj = ConfigurationService(session)
            obj.session = session;
        end
        
        function o = getOptions(obj)
            o = obj.session.options;
        end
        
    end
    
end

