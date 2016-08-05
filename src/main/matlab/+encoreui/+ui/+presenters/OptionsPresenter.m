classdef OptionsPresenter < appbox.Presenter
    
    properties
        options
    end
    
    methods
        
        function obj = OptionsPresenter(options, view)
            if nargin < 2
                view = encoreui.ui.views.OptionsView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.options = options;
        end
        
    end
    
    methods (Access = protected)
        
        function willGo(obj)
            obj.populateDetails();
        end

        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'SelectedNode', @obj.onViewSelectedNode);
            obj.addListener(v, 'Save', @obj.onViewSelectedSave);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
        
    end
    
    methods (Access = private)
        
        function populateDetails(obj)
            obj.populateGeneralDetails();
        end
        
        function populateGeneralDetails(obj)
            
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedSave();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedNode(obj, ~, ~)
            index = obj.view.getSelectedNode();
            obj.view.setCardSelection(index);
        end
        
        function onViewSelectedSave(obj, ~, ~)
            obj.view.update();
            
            obj.stop();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end
        
    end
    
end

