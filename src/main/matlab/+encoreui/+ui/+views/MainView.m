classdef MainView < appbox.View
    
    events
        ConfigureOptions
        ShowDocumentation
        ShowUserGroup
        ShowAbout
    end
    
    properties (Access = private)
        fileMenu
        configureMenu
        helpMenu
        toolbar
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Encore', ...
                'Position', screenCenter(1024, 768));
            
            % File menu.
            obj.fileMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'File');
            
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
            
            obj.toolbar = Menu(obj.figureHandle);
            
            mainLayout = uix.HBoxFlex( ...
                'Parent', obj.figureHandle, ...
                'DividerMarkings', 'off', ...
                'DividerBackgroundColor', [160/255 160/255 160/255], ...
                'Spacing', 1);
            
            masterLayout = uix.HBox( ...
                'Parent', mainLayout);
            
            detailLayout = uix.VBox( ...
                'Parent', mainLayout, ...
                'Padding', 11);
            
            set(mainLayout, 'Widths', [-1 -2]);
        end
        
    end
    
end

