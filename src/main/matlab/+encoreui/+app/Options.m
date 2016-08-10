classdef Options < appbox.Settings
    
    properties
        
    end
    
    methods
        
    end
    
    methods (Static)

        function o = getDefault()
            persistent default;
            if isempty(default) || ~isvalid(default)
                default = encoreui.app.Options();
            end
            o = default;
        end

    end
    
end

