classdef MainView < appbox.View
    
    properties
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Encore', ...
                'Position', screenCenter(300, 300));
        end
        
    end
    
end

