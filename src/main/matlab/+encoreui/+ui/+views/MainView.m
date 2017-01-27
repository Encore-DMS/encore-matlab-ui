classdef MainView < appbox.View

    events
        AddDataStore
        Exit
        ToggleDataStoreList
        ConfigureOptions
        ShowDocumentation
        ShowUserGroup
        ShowAbout
        SelectedDataStoreNode
        QueryDataStore
        SyncDataStore
        SelectedEntityNodes
    end

    properties (Access = private)
        fileMenu
        viewMenu
        configureMenu
        helpMenu
        mainLayout
        toggleDataStoreListButton
        dataStoreTree
        detailCardPanel
        emptyCard
        dataStoreCard
    end

    properties (Constant)
        EMPTY_CARD                  = 1
        DATA_STORE_CARD             = 2
        
        EMPTY_ENTITY_CARD           = 1
        PROJECT_ENTITY_CARD         = 2
        EXPERIMENT_ENTITY_CARD      = 3
        SOURCE_ENTITY_CARD          = 4
        EPOCH_GROUP_ENTITY_CARD     = 5
        EPOCH_BLOCK_ENTITY_CARD     = 6
        EPOCH_ENTITY_CARD           = 7
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'Encore', ...
                'Position', screenCenter(hpix(1024/11), vpix(768/16)));

            % File menu.
            obj.fileMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'File');
            obj.fileMenu.addDataStore = uimenu(obj.fileMenu.root, ...
                'Label', 'Add Data Store...', ...
                'Callback', @(h,d)notify(obj, 'AddDataStore'));
            obj.fileMenu.exit = uimenu(obj.fileMenu.root, ...
                'Label', 'Exit', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'Exit'));
            
            % View menu.
            obj.viewMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'View');
            obj.viewMenu.toggleDataStoreList = uimenu(obj.viewMenu.root, ...
                'Label', 'Toggle Data Store List', ...
                'Callback', @(h,d)notify(obj, 'ToggleDataStoreList'));

            % Configure menu.
            obj.configureMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Configure');
            obj.configureMenu.configureOptions = uimenu(obj.configureMenu.root, ...
                'Label', 'Options', ...
                'Callback', @(h,d)notify(obj, 'ConfigureOptions'));

            % Help menu.
            obj.helpMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Help');
            obj.helpMenu.showDocumentation = uimenu(obj.helpMenu.root, ...
                'Label', 'Documentation', ...
                'Callback', @(h,d)notify(obj, 'ShowDocumentation'));
            obj.helpMenu.showUserGroup = uimenu(obj.helpMenu.root, ...
                'Label', 'User Group', ...
                'Callback', @(h,d)notify(obj, 'ShowUserGroup'));
            obj.helpMenu.showAbout = uimenu(obj.helpMenu.root, ...
                'Label', ['About ' encoreui.app.App.name], ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'ShowAbout'));

            obj.mainLayout = uix.HBoxFlex( ...
                'Parent', obj.figureHandle, ...
                'DividerMarkings', 'off', ...
                'DividerBackgroundColor', [160/255 160/255 160/255], ...
                'Spacing', 1);

            masterLayout = uix.VBox( ...
                'Parent', obj.mainLayout);
            
            dataStoreListToolbarLayout = uix.HBox( ...
                'Parent', masterLayout);
            uix.Empty('Parent', dataStoreListToolbarLayout);
            Label( ...
                'Parent', dataStoreListToolbarLayout, ...
                'String', 'Data Stores');
            obj.toggleDataStoreListButton = Button( ...
                'Parent', dataStoreListToolbarLayout, ...
                'Icon', encoreui.app.App.getResource('icons', 'sidebar_toggle.png'), ...
                'TooltipString', 'Toggle Data Store List', ...
                'Callback', @(h,d)notify(obj, 'ToggleDataStoreList'));
            set(dataStoreListToolbarLayout, 'Widths', [hpix(5/11) -1 hpix(26/11)]);
            
            Separator('Parent', masterLayout);

            obj.dataStoreTree = uiextras.jTree.Tree( ...
                'Parent', masterLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'BorderType', 'none', ...
                'RootVisible', false, ...
                'SelectionChangeFcn', @(h,d)notify(obj, 'SelectedDataStoreNode'), ...
                'SelectionType', 'single');
            
            set(masterLayout, 'Heights', [vpix(26/16) 1 -1]);

            detailLayout = uix.VBox( ...
                'Parent', obj.mainLayout);

            obj.detailCardPanel = uix.CardPanel( ...
                'Parent', detailLayout);

            % Empty card.
            emptyLayout = uix.VBox( ...
                'Parent', obj.detailCardPanel);
            uix.Empty('Parent', emptyLayout);
            obj.emptyCard.text = uicontrol( ...
                'Parent', emptyLayout, ...
                'Style', 'text', ...
                'HorizontalAlignment', 'center');
            uix.Empty('Parent',emptyLayout);
            set(emptyLayout, ...
                'Heights', [-1 vpix(23/16) -1], ...
                'UserData', struct('Height', -1));

            % Data store card.
            dataStoreLayout = uix.VBox( ...
                'Parent', obj.detailCardPanel);

            dataStoreToolbarLayout = uix.HBox( ...
                'Parent', dataStoreLayout);
            obj.dataStoreCard.queryButton = Button( ...
                'Parent', dataStoreToolbarLayout, ...
                'Icon', encoreui.app.App.getResource('icons', 'query.png'), ...
                'String', 'Query', ...
                'Callback', @(h,d)notify(obj, 'QueryDataStore'));
            uix.Empty('Parent', dataStoreToolbarLayout);
            obj.dataStoreCard.syncButton = Button( ...
                'Parent', dataStoreToolbarLayout, ...
                'Icon', encoreui.app.App.getResource('icons', 'sync.png'), ...
                'String', 'Sync', ...
                'Callback', @(h,d)notify(obj, 'SyncDataStore'));
            set(dataStoreToolbarLayout, 'Widths', [hpix(84/11) -1 hpix(84/11)]);

            Separator('Parent', dataStoreLayout);

            dataStoreMasterDetailLayout = uix.HBoxFlex( ...
                'Parent', dataStoreLayout, ...
                'DividerMarkings', 'off', ...
                'DividerBackgroundColor', [160/255 160/255 160/255], ...
                'Spacing', 1);

            dataStoreMasterLayout = uix.HBox( ...
                'Parent', dataStoreMasterDetailLayout);

            obj.dataStoreCard.entityTree = uiextras.jTree.Tree( ...
                'Parent', dataStoreMasterLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'BorderType', 'none', ...
                'RootVisible', false, ...
                'SelectionChangeFcn', @(h,d)notify(obj, 'SelectedEntityNodes'), ...
                'SelectionType', 'discontiguous');

            dataStoreDetailLayout = uix.VBox( ...
                'Parent', dataStoreMasterDetailLayout, ...
                'Padding', 11);
            
            obj.dataStoreCard.detailCardPanel = uix.CardPanel( ...
                'Parent', dataStoreDetailLayout);
            
            % Empty card.
            emptyLayout = uix.VBox( ...
                'Parent', obj.dataStoreCard.detailCardPanel);
            uix.Empty('Parent', emptyLayout);
            obj.dataStoreCard.emptyCard.text = uicontrol( ...
                'Parent', emptyLayout, ...
                'Style', 'text', ...
                'HorizontalAlignment', 'center');
            uix.Empty('Parent',emptyLayout);
            set(emptyLayout, ...
                'Heights', [-1 23 -1], ...
                'UserData', struct('Height', -1));
            
            % Project card.
            projectLayout = uix.VBox( ...
                'Parent', obj.dataStoreCard.detailCardPanel, ...
                'Spacing', 7);
            projectGrid = uix.Grid( ...
                'Parent', projectLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', projectGrid, ...
                'String', 'Name:');
            Label( ...
                'Parent', projectGrid, ...
                'String', 'Purpose:');
            obj.dataStoreCard.projectCard.nameField = uicontrol( ...
                'Parent', projectGrid, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SetProjectName'));
            obj.dataStoreCard.projectCard.purposeField = uicontrol( ...
                'Parent', projectGrid, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SetProjectPurpose'));
            set(projectGrid, ...
                'Widths', [60 -1], ...
                'Heights', [23 23]);
            obj.dataStoreCard.projectCard.annotationsLayout = uix.VBox( ...
                'Parent', projectLayout);
            set(projectLayout, ...
                'Heights', [layoutHeight(projectGrid) -1]);

            set(dataStoreMasterDetailLayout, 'Widths', [-1 -2]);

            set(dataStoreLayout, 'Heights', [vpix(26/16) 1 -1]);

            obj.setCardSelection(obj.EMPTY_CARD);

            set(obj.mainLayout, 'Widths', [-1 -4]);
        end

        function show(obj)
            show@appbox.View(obj);

            % FIXME: This is needed to correct the font on Buttons
            set(obj.dataStoreCard.queryButton, 'String', get(obj.dataStoreCard.queryButton, 'String'));
            set(obj.dataStoreCard.syncButton, 'String', get(obj.dataStoreCard.syncButton, 'String'));
        end
        
        function setCardSelection(obj, index)
            set(obj.detailCardPanel, 'Selection', index);
        end
        
        function toggleDataStoreList(obj, tf)
            set(obj.mainLayout, 'Widths', [-1*tf -4]);
            set(obj.mainLayout, 'Spacing', 1*tf);
        end
        
        function tf = getToggleDataStoreList(obj)
            w = get(obj.mainLayout, 'Widths');
            tf = w(1) ~= 0;
        end

        function n = getDataStoreTreeRootNode(obj)
            n = obj.dataStoreTree.Root;
        end

        function n = addDataStoreNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = encoreui.ui.views.DataStoreNodeType.DATA_STORE;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(encoreui.app.App.getResource('icons', 'data_store.png'));
        end

        function n = getSelectedDataStoreNode(obj)
            n = appbox.firstOrElse(obj.dataStoreTree.SelectedNodes, []);
        end
        
        function setSelectedDataStoreNode(obj, node)
            obj.dataStoreTree.SelectedNodes = node;
        end
        
        function setEntityCardSelection(obj, index)
            set(obj.dataStoreCard.detailCardPanel, 'Selection', index);
        end
        
        function n = getEntityTreeRootNode(obj)
            n = obj.dataStoreCard.entityTree.Root;
        end
        
        function clearEntityTree(obj)
            root = obj.dataStoreCard.entityTree.Root;
            delete(root.Children(isvalid(root.Children)));
        end
        
        function setEmptyText(obj, t)
            set(obj.dataStoreCard.emptyCard.text, 'String', t);
        end
        
        function n = addProjectNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = encoreui.ui.views.EntityNodeType.PROJECT;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(encoreui.app.App.getResource('icons', 'project.png'));
        end
        
        function setProjectName(obj, n)
            set(obj.dataStoreCard.projectCard.nameField, 'String', n);
        end
        
        function setProjectPurpose(obj, p)
            set(obj.dataStoreCard.projectCard.purposeField, 'String', p);
        end
        
        function n = addExperimentNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = encoreui.ui.views.EntityNodeType.EXPERIMENT;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(encoreui.app.App.getResource('icons', 'experiment.png'));
        end
        
        function n = getSelectedEntityNodes(obj)
            n = obj.dataStoreCard.entityTree.SelectedNodes;
        end
        
        function setSelectedEntityNodes(obj, nodes)
            obj.dataStoreCard.entityTree.SelectedNodes = nodes;
        end

        function e = getNodeEntity(obj, node)
            v = get(node, 'Value');
            e = v.entity;
        end

        function t = getNodeType(obj, node)
            v = get(node, 'Value');
            t = v.type;
        end
        
        function removeNode(obj, node)
            node.delete();
        end
        
        function collapseNode(obj, node)
            node.collapse();
        end
        
        function expandNode(obj, node)
            node.expand();
        end

        function setQueryString(obj, s)
            obj.dataStoreCard.queryButton.String = s;
        end

    end

end
