classdef QueryPresenter < appbox.Presenter
    
    properties (Access = private)
        log
    end
    
    methods
        
        function obj = QueryPresenter(view)
            if nargin < 1
                view = encoreui.ui.views.QueryView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.log = log4m.LogManager.getLogger(class(obj));
        end
        
    end
    
    methods (Access = protected)

        function didGo(obj)
            obj.view.requestQlStringFocus();
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Query', @obj.onViewSelectedQuery);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end
    
    methods (Access = private)
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    if obj.view.getEnableQuery()
                        obj.onViewSelectedQuery();
                    end
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedQuery(obj, ~, ~)
            obj.view.update();
            
            try
                obj.disableControls();
                obj.view.startSpinner();
                obj.view.update();
                
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                obj.view.stopSpinner();
                obj.updateStateOfControls();
                return;
            end
            
            obj.stop();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end
        
        function disableControls(obj)
            obj.view.enableQuery(false);
            obj.view.enableCancel(false);
            obj.view.enableSelectType(false);
            obj.view.enableQlString(false);
        end
        
        function updateStateOfControls(obj)
            obj.view.enableQuery(true);
            obj.view.enableCancel(true);
            obj.view.enableSelectType(true);
            obj.view.enableQlString(true);
        end
        
    end
    
end

