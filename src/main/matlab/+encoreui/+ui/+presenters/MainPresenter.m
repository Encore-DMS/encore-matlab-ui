classdef MainPresenter < appbox.Presenter
    
    properties
        log
        dataSourceService
        configurationService
    end
    
    methods
        
        function obj = MainPresenter(dataSourceService, configurationService, view)
            if nargin < 3
                view = encoreui.ui.views.MainView();
            end
            obj = obj@appbox.Presenter(view);
            
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.dataSourceService = dataSourceService;
            obj.configurationService = configurationService;
        end
        
    end
    
    methods (Access = protected)
        
        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'AddDataSource', @obj.onViewSelectedAddDataSource);
            obj.addListener(v, 'Exit', @obj.onViewSelectedExit);
            obj.addListener(v, 'ConfigureOptions', @obj.onViewSelectedConfigureOptions);
            obj.addListener(v, 'ShowDocumentation', @obj.onViewSelectedShowDocumentation);
            obj.addListener(v, 'ShowUserGroup', @obj.onViewSelectedShowUserGroup);
            obj.addListener(v, 'ShowAbout', @obj.onViewSelectedShowAbout);
            
            d = obj.dataSourceService;
            obj.addListener(d, 'AddedDataSource', @obj.onServiceAddedDataSource);
        end
        
    end
    
    methods (Access = private)
        
        function onViewSelectedAddDataSource(obj, ~, ~)
            presenter = encoreui.ui.presenters.AddDataSourcePresenter(obj.dataSourceService);
            presenter.goWaitStop();
        end
        
        function onServiceAddedDataSource(obj, ~, event)
            source = event.data;
            node = obj.addDataSourceNode(source);
        end
        
        function n = addDataSourceNode(obj, source)
            parent = obj.view.getDataSourceRootNode();
            
            n = obj.view.addDataSourceNode(parent, source.url, source);
        end
        
        function onViewSelectedExit(obj, ~, ~)
            obj.stop();
        end
        
        function onViewSelectedConfigureOptions(obj, ~, ~)
            options = obj.configurationService.getOptions();
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

