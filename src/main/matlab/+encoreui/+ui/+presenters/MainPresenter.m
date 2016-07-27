classdef MainPresenter < appbox.Presenter
    
    properties
    end
    
    methods
        
        function obj = MainPresenter(view)
            if nargin < 1
                view = encoreui.ui.views.MainView();
            end
            obj = obj@appbox.Presenter(view);
        end
        
    end
    
end

