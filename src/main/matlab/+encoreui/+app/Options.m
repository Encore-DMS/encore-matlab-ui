classdef Options < appbox.Settings
    
    properties
        accountLogin
    end
    
    methods
        
        function l = get.accountLogin(obj)
            l = obj.get('accountLogin', '');
        end
        
        function set.accountLogin(obj, l)
            validateattributes(l, {'char'}, {'2d'});
            obj.put('accountLogin', l);
        end
        
    end
    
end

