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
    
    methods (Access = protected)
        
        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'CloneDataStore', @obj.onViewSelectedCloneDataStore);
            obj.addListener(v, 'AddLocalDataStore', @obj.onViewSelectedAddLocalDataStore);
            obj.addListener(v, 'Exit', @obj.onViewSelectedExit);
            obj.addListener(v, 'ConfigureOptions', @obj.onViewSelectedConfigureOptions);
            obj.addListener(v, 'ShowDocumentation', @obj.onViewSelectedShowDocumentation);
            obj.addListener(v, 'ShowUserGroup', @obj.onViewSelectedShowUserGroup);
            obj.addListener(v, 'ShowAbout', @obj.onViewSelectedShowAbout);
        end
        
    end
    
    methods (Access = private)
        
        function onViewSelectedCloneDataStore(obj, ~, ~)
            disp('Selected clone data store');
        end
        
        function onViewSelectedAddLocalDataStore(obj, ~, ~)
            path = obj.view.showGetFile('Data Store Location');
            if isempty(path)
                return;
            end
        end
        
        function onViewSelectedExit(obj, ~, ~)
            obj.stop();
        end
        
        function onViewSelectedConfigureOptions(obj, ~, ~)
            options = [];
            presenter = encoreui.ui.presenters.OptionsPresenter(options);
            presenter.goWaitStop();
        end
        
        function onViewSelectedShowDocumentation(obj, ~, ~)
            obj.view.showWeb(encoreui.app.App.documentationUrl, '-helpbrowser');
        end

        function onViewSelectedShowUserGroup(obj, ~, ~)
            obj.view.showWeb(encoreui.app.App.userGroupUrl);
        end

        function onViewSelectedShowAbout(obj, ~, ~)
            message = sprintf('%s %s\nVersion %s\n%s', ...
                encoreui.app.App.name, ...
                encoreui.app.App.description, ...
                encoreui.app.App.version, ...
                [char(169) ' ' datestr(now, 'yyyy') ' ' encoreui.app.App.owner]);
            obj.view.showMessage(message, ['About ' encoreui.app.App.name]);
        end
        
    end
    
end

