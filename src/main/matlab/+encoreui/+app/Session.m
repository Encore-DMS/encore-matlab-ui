classdef Session < handle
    
    properties (SetAccess = private)
        options
    end
    
    methods
        
        function obj = Session(options)
            obj.options = options;
        end
        
    end
    
end

