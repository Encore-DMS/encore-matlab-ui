classdef CloneDataStorePresenter < appbox.Presenter
    
    properties (Access = private)
        
    end
    
    methods
        
        function obj = CloneDataStorePresenter(view)
            if nargin < 1
                view = encoreui.ui.views.CloneDataStoreView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');
        end
        
    end
    
    methods (Access = protected)
        
        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Clone', @obj.onViewSelectedClone);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
        
    end
    
    methods (Access = private)
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedClone();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedClone(obj, ~, ~)
            obj.stop();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end
        
    end
    
end

