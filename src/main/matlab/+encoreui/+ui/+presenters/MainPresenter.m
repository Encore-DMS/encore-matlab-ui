classdef MainPresenter < appbox.Presenter

    properties (Access = private)
        log
        dataStoreService
        configurationService
        uuidToNode
    end

    methods

        function obj = MainPresenter(dataStoreService, configurationService, view)
            if nargin < 3
                view = encoreui.ui.views.MainView();
            end
            obj = obj@appbox.Presenter(view);

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.dataStoreService = dataStoreService;
            obj.configurationService = configurationService;
            obj.uuidToNode = containers.Map();
        end

    end

    methods (Access = protected)

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'AddDataStore', @obj.onViewSelectedAddDataStore);
            obj.addListener(v, 'Exit', @obj.onViewSelectedExit);
            obj.addListener(v, 'ToggleDataStoreList', @obj.onViewToggleDataStoreList);
            obj.addListener(v, 'ConfigureOptions', @obj.onViewSelectedConfigureOptions);
            obj.addListener(v, 'ShowDocumentation', @obj.onViewSelectedShowDocumentation);
            obj.addListener(v, 'ShowUserGroup', @obj.onViewSelectedShowUserGroup);
            obj.addListener(v, 'ShowAbout', @obj.onViewSelectedShowAbout);
            obj.addListener(v, 'SelectedDataStoreNode', @obj.onViewSelectedDataStoreNode);
            obj.addListener(v, 'QueryDataStore', @obj.onViewSelectedQueryDataStore);
            obj.addListener(v, 'SyncDataStore', @obj.onViewSelectedSyncDataStore);

            d = obj.dataStoreService;
            obj.addListener(d, 'AddedDataStore', @obj.onServiceAddedDataStore);
        end

    end

    methods (Access = private)

        function onViewSelectedAddDataStore(obj, ~, ~)
            presenter = encoreui.ui.presenters.AddDataStorePresenter(obj.dataStoreService);
            presenter.goWaitStop();
        end

        function onServiceAddedDataStore(obj, ~, event)
            coordinator = event.data;
            node = obj.addDataStoreNode(coordinator);
            
            obj.view.update();
            obj.view.setSelectedDataStoreNode(node);
            
            obj.populateDetailsForDataStore(coordinator);
        end

        function n = addDataStoreNode(obj, coordinator)
            parent = obj.view.getDataStoreTreeRootNode();
            n = obj.view.addDataStoreNode(parent, coordinator.getPrimaryDataStore().url, coordinator);
        end

        function onViewSelectedDataStoreNode(obj, ~, ~)
            coordinator = obj.getSelectedDataStore();
            obj.populateDetailsForDataStore(coordinator);
        end

        function populateDetailsForDataStore(obj, coordinator)
            obj.populateEntityTreeForDataStore(coordinator);
            
            obj.view.setCardSelection(obj.view.DATA_STORE_CARD);
        end
        
        function populateEntityTreeForDataStore(obj, coordinator)
            obj.view.clearEntityTree();
            
            context = coordinator.getContext();
            projects = context.getProjects();
            for i = 1:numel(projects)
                obj.addProjectNode(projects{i});
            end
        end
        
        function n = addProjectNode(obj, project)
            parent = obj.view.getEntityTreeRootNode();
            n = obj.view.addProjectNode(parent, project.name, project);
            obj.uuidToNode(project.uuid) = n;
        end
        
        function n = addExperimentNode(obj, project, experiment)
            parent = obj.uuidToNode(project.uuid);
            if isempty(experiment.purpose)
                name = datestr(experiment.startTime, 1);
            else
                name = [experiment.purpose ' [' datestr(experiment.startTime, 1) ']'];
            end
            n = obj.view.addExperimentNode(parent, name, experiment);
        end

        function onViewSelectedQueryDataStore(obj, ~, ~)
            disp('Selected query data store');
        end

        function onViewSelectedSyncDataStore(obj, ~, ~)
            disp('Selected sync data store');
        end

        function s = getSelectedDataStore(obj)
            node = obj.view.getSelectedDataStoreNode();
            s = obj.view.getNodeEntity(node);
        end

        function onViewSelectedExit(obj, ~, ~)
            obj.stop();
        end
        
        function onViewToggleDataStoreList(obj, ~, ~)
            tf = obj.view.getToggleDataStoreList();
            obj.view.toggleDataStoreList(~tf);
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
            obj.view.showMessage(message, ['About ' encoreui.app.App.name], ...
                'width', 250);
        end

    end

end
