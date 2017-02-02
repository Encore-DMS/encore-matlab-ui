classdef MainPresenter < appbox.Presenter

    properties (Access = private)
        log
        dataStoreService
        configurationService
        detailedEntityNodes
        uuidToNodes
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
            obj.detailedEntityNodes = [];
            obj.uuidToNodes = containers.Map();
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
            obj.addListener(v, 'SelectedEntityNodes', @obj.onViewSelectedEntityNodes);
            obj.addListener(v, 'EntityNodeExpanded', @obj.onViewEntityNodeExpanded);
            obj.addListener(v, 'SetProjectName', @obj.onViewSetProjectName);
            obj.addListener(v, 'SetProjectPurpose', @obj.onViewSetProjectPurpose);
            obj.addListener(v, 'SetExperimentPurpose', @obj.onViewSetExperimentPurpose);
            obj.addListener(v, 'SendEntityToWorkspace', @obj.onViewSelectedSendEntityToWorkspace);
            obj.addListener(v, 'ReloadEntity', @obj.onViewSelectedReloadEntity);
            obj.addListener(v, 'DeleteEntity', @obj.onViewSelectedDeleteEntity);

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
            obj.view.stopEditingProperties();
            obj.view.update();
            
            coordinator = obj.getSelectedDataStore();
            if isempty(coordinator)
                obj.view.setCardSelection(obj.view.EMPTY_CARD);
                return;
            end
            obj.populateDetailsForDataStore(coordinator);
            obj.detailedEntityNodes = [];
        end

        function populateDetailsForDataStore(obj, coordinator)
            obj.populateEntityTreeForDataStore(coordinator);
            
            obj.view.setCardSelection(obj.view.DATA_STORE_CARD);
            
            obj.populateEntityDetailsForHeterogeneousEntitySet(encore.core.collections.EntitySet({}));
        end
        
        function populateEntityTreeForDataStore(obj, coordinator)
            obj.view.clearEntityTree();
            obj.uuidToNodes = containers.Map();
            
            context = coordinator.getContext();
            projects = context.getProjects();
            parentNode = obj.view.getEntityTreeRootNode();
            for i = 1:numel(projects)
                obj.addProjectNode(projects{i}, parentNode);
            end
        end
        
        function n = addProjectNode(obj, project, parentNode)
            n = obj.view.addProjectNode(parentNode, project.name, project);
            
            if obj.uuidToNodes.isKey(project.uuid)
                obj.uuidToNodes(project.uuid) = [obj.uuidToNodes(project.uuid), n];
            else
                obj.uuidToNodes(project.uuid) = n;
            end
            
            obj.view.addPlaceholderNode(n);
        end
        
        function addProjectNodeChildren(obj, projectNode)
            project = obj.view.getNodeEntity(projectNode);
            experiments = project.getExperiments();
            for i = 1:numel(experiments)
                obj.addExperimentNode(experiments{i}, projectNode);
            end
        end
        
        function populateEntityDetailsForProjectSet(obj, projectSet)
            obj.view.enableProjectName(projectSet.size == 1);
            obj.view.setProjectName(projectSet.name);
            obj.view.enableProjectPurpose(projectSet.size == 1);
            obj.view.setProjectPurpose(projectSet.purpose);
            obj.view.setProjectStartTime(strtrim(datestr(projectSet.startTime, 14)));
            obj.view.setEntityCardSelection(obj.view.PROJECT_ENTITY_CARD);
            
            obj.populateCommonEntityDetailsForEntitySet(projectSet);
        end
        
        function onViewSetProjectName(obj, ~, ~)
            projectSet = obj.getDetailedEntitySet();
            try
                projectSet.name = obj.view.getProjectName();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            obj.updateEntityNodeNamesForProjectSet(projectSet);
        end
        
        function updateEntityNodeNamesForProjectSet(obj, projectSet)
            for i = 1:projectSet.size
                project = projectSet.get(i);
                nodes = obj.uuidToNodes(project.uuid);
                arrayfun(@(n)obj.view.setNodeName(n, project.name), nodes);
            end
        end
        
        function onViewSetProjectPurpose(obj, ~, ~)
            projectSet = obj.getDetailedEntitySet();
            try
                projectSet.purpose = obj.view.getProjectPurpose();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function n = addExperimentNode(obj, experiment, parentNode)
            if isempty(experiment.purpose)
                name = datestr(experiment.startTime, 1);
            else
                name = [experiment.purpose ' [' datestr(experiment.startTime, 1) ']'];
            end
            n = obj.view.addExperimentNode(parentNode, name, experiment);
            
            if obj.uuidToNodes.isKey(experiment.uuid)
                obj.uuidToNodes(experiment.uuid) = [obj.uuidToNodes(experiment.uuid), n];
            else
                obj.uuidToNodes(experiment.uuid) = n;
            end
            
            obj.view.addPlaceholderNode(n);
        end
        
        function addExperimentNodeChildren(obj, experimentNode)
            
        end
        
        function populateEntityDetailsForExperimentSet(obj, experimentSet)
            obj.view.enableExperimentPurpose(experimentSet.size == 1);
            obj.view.setExperimentPurpose(experimentSet.purpose);
            obj.view.setExperimentStartTime(strtrim(datestr(experimentSet.startTime, 14)));
            obj.view.setExperimentEndTime(strtrim(datestr(experimentSet.endTime, 14)));
            obj.view.setEntityCardSelection(obj.view.EXPERIMENT_ENTITY_CARD);
            
            obj.populateCommonEntityDetailsForEntitySet(experimentSet);
        end
        
        function onViewSetExperimentPurpose(obj, ~, ~)
            experimentSet = obj.getDetailedEntitySet();
            try
                experimentSet.purpose = obj.view.getExperimentPurpose();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            obj.updateEntityNodeNamesForExperimentSet(experimentSet);
        end
        
        function updateEntityNodeNamesForExperimentSet(obj, experimentSet)
            for i = 1:experimentSet.size
                experiment = experimentSet.get(i);
                
                if isempty(experiment.purpose)
                    name = datestr(experiment.startTime, 1);
                else
                    name = [experiment.purpose ' [' datestr(experiment.startTime, 1) ']'];
                end
                nodes = obj.uuidToNodes(experiment.uuid);
                arrayfun(@(n)obj.view.setNodeName(n, name), nodes);
            end
        end

        function onViewSelectedQueryDataStore(obj, ~, ~)
            disp('query data store');
        end

        function onViewSelectedSyncDataStore(obj, ~, ~)
            disp('sync data store');
        end

        function s = getSelectedDataStore(obj)
            node = obj.view.getSelectedDataStoreNode();
            if ~isempty(node)
                s = obj.view.getNodeEntity(node);
            else
                s = [];
            end
        end
        
        function addEntityNodeChildren(obj, entityNode)
            import encoreui.ui.views.EntityNodeType;
            
            switch obj.view.getNodeType(entityNode)
                case EntityNodeType.PROJECT
                    obj.addProjectNodeChildren(entityNode);
                case EntityNodeType.EXPERIMENT
                    obj.addExperimentNodeChildren(entityNode);
            end
        end
        
        function populateEntityDetailsForHeterogeneousEntitySet(obj, entitySet)
            obj.view.setEmptyEntityText('');
            obj.view.setEntityCardSelection(obj.view.EMPTY_ENTITY_CARD);
            
            obj.populateCommonEntityDetailsForEntitySet(entitySet);
        end
        
        function onViewSelectedEntityNodes(obj, ~, ~)
            obj.view.stopEditingProperties();
            obj.view.update();
            
            [set, nodes] = obj.getSelectedEntitySet();
            obj.populateEntityDetailsForEntitySet(set);
            obj.detailedEntityNodes = nodes;
        end
        
        function populateEntityDetailsForEntitySet(obj, entitySet)
            import encore.core.EntityType;
            
            if entitySet.size == 0
                obj.populateEntityDetailsForHeterogeneousEntitySet(entitySet);
                return;
            end
            
            switch entitySet.getEntityType()
                case EntityType.PROJECT
                    obj.populateEntityDetailsForProjectSet(entitySet);
                case EntityType.EXPERIMENT
                    obj.populateEntityDetailsForExperimentSet(entitySet);
                case EntityType.SOURCE
                    obj.populateEntityDetailsForSourceSet(entitySet);
                case EntityType.EPOCH_GROUP
                    obj.populateEntityDetailsForEpochGroupSet(entitySet);
                case EntityType.EPOCH_BLOCK
                    obj.populateEntityDetailsForEpochBlockSet(entitySet);
                case EntityType.EPOCH
                    obj.populateEntityDetailsForEpochSet(entitySet);
                otherwise
                    obj.populateEntityDetailsForHeterogeneousEntitySet(entitySet);
            end
        end
        
        function populateCommonEntityDetailsForEntitySet(obj, entitySet)
            
        end
        
        function onViewEntityNodeExpanded(obj, ~, event)
            import encoreui.ui.views.EntityNodeType;
            
            node = event.data.Nodes(1);
            children = obj.view.getNodeChildren(node);
            if numel(children) ~= 1 || obj.view.getNodeType(children(1)) ~= encoreui.ui.views.EntityNodeType.PLACEHOLDER
                return;
            end
            
            obj.addEntityNodeChildren(node);
            
            obj.view.removeNode(children(1));
        end
        
        function onViewSelectedSendEntityToWorkspace(obj, ~, ~)
            nodes = obj.detailedEntityNodes;
            for i = 1:numel(nodes)
                entity = obj.view.getNodeEntity(nodes(i));
                try
                    obj.dataStoreService.sendEntityToWorkspace(entity);
                catch x
                    obj.log.debug(x.message, x);
                    obj.view.showError(x.message);
                    return;
                end
            end
        end
        
        function onViewSelectedReloadEntity(obj, ~, ~)
            nodes = obj.detailedEntityNodes;
            for i = 1:numel(nodes)
                node = nodes(i);
                children = obj.view.getNodeChildren(node);
                
                tempNode = obj.view.addPlaceholderNode(node, 1);
                
                for k = 1:numel(children)
                    child = children(k);
                    
                    entity = obj.view.getNodeEntity(child);
                    obj.view.removeNode(child);
                    
                    n = obj.uuidToNodes(entity.uuid);
                    obj.uuidToNodes(entity.uuid) = n(n ~= child);
                end
                
                obj.addEntityNodeChildren(node);
                
                obj.view.removeNode(tempNode);                
            end
        end
        
        function onViewSelectedDeleteEntity(obj, ~, ~)
            disp('delete entity');
        end
        
        function [s, n] = getSelectedEntitySet(obj)
            n = obj.view.getSelectedEntityNodes();
            s = obj.getEntitySetFromNodes(n);
        end
        
        function [s, n] = getDetailedEntitySet(obj)
            n = obj.detailedEntityNodes;
            s = obj.getEntitySetFromNodes(n);
        end
        
        function s = getEntitySetFromNodes(obj, nodes)
            import encoreui.ui.views.EntityNodeType;
            import encore.core.collections.*;
            
            entities = {};
            types = EntityNodeType.empty(0, numel(nodes));
            for i = 1:numel(nodes)
                entity = obj.view.getNodeEntity(nodes(i));
                if ~isempty(entity)
                    entities{end + 1} = entity; %#ok<AGROW>
                end
                types(i) = obj.view.getNodeType(nodes(i));
            end
            
            types = unique(types);
            if numel(types) ~= 1
                s = EntitySet({});
                return;
            end
            type = types(1);
            
            switch type
                case EntityNodeType.PROJECT
                    s = ProjectSet(entities);
                case EntityNodeType.EXPERIMENT
                    s = ExperimentSet(entities);
                case EntityNodeType.SOURCE
                    s = SourceSet(entities);
                case EntityNodeType.EPOCH_GROUP
                    s = EpochGroupSet(entities);
                case EntityNodeType.EPOCH_BLOCK
                    s = EpochBlockSet(entities);
                case EntityNodeType.EPOCH
                    s = EpochSet(entities);
                otherwise
                    s = EntitySet(entities);
            end
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
