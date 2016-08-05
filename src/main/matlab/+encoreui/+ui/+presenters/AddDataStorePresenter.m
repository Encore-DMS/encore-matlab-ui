classdef AddDataStorePresenter < appbox.Presenter
    
    properties (Access = private)
        
    end
    
    methods
        
        function obj = AddDataStorePresenter(view)
            if nargin < 1
                view = encoreui.ui.views.AddDataStoreView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');
        end
        
    end
    
    methods (Access = protected)
        
        function didGo(obj)
            obj.view.requestHostFocus();
        end
        
        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Add', @obj.onViewSelectedAdd);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
        
    end
    
    methods (Access = private)
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();
            
            host = obj.view.getHost();
            port = str2double(obj.view.getPort());
            user = obj.view.getUser();
            password = obj.view.getPassword();
            
            disp(host);
            disp(port);
            disp(user);
            disp(password);
            
            obj.stop();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end
        
    end
    
end

