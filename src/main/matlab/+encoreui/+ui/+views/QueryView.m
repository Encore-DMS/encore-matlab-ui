classdef QueryView < appbox.View
    
    events
        Query
        Cancel
    end
    
    properties (Access = private)
        typePopupMenu
        qlStringField
        spinner
        queryButton
        cancelButton
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Query', ...
                'Position', screenCenter(hpix(330/11), vpix(109/16)), ...
                'Resize', 'off');
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);
            
            queryLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', queryLayout, ...
                'String', 'Type:');
            Label( ...
                'Parent', queryLayout, ...
                'String', 'Query:');
            obj.typePopupMenu = MappedPopupMenu( ...
                'Parent', queryLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            obj.qlStringField = uicontrol( ...
                'Parent', queryLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            set(queryLayout, ...
                'Widths', [hpix(45/11) -1], ...
                'Heights', [vpix(23/16) vpix(23/16)]);
            
            % Query/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            spinnerLayout = uix.VBox( ...
                'Parent', controlsLayout);
            uix.Empty('Parent', spinnerLayout);
            obj.spinner = com.mathworks.widgets.BusyAffordance();
            javacomponent(obj.spinner.getComponent(), [], spinnerLayout);
            set(spinnerLayout, 'Heights', [4 -1]);
            uix.Empty('Parent', controlsLayout);
            obj.queryButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Query', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Query'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [hpix(16/11) -1 hpix(75/11) hpix(75/11)]);

            set(mainLayout, 'Heights', [-1 vpix(23/16)]);

            % Set query button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.queryButton);
            end
        end
        
        function enableQuery(obj, tf)
            set(obj.queryButton, 'Enable', appbox.onOff(tf));
        end
        
        function tf = getEnableQuery(obj)
            tf = appbox.onOff(get(obj.queryButton, 'Enable'));
        end
        
        function enableCancel(obj, tf)
            set(obj.cancelButton, 'Enable', appbox.onOff(tf));
        end
        
        function enableSelectType(obj, tf)
            set(obj.typePopupMenu, 'Enable', appbox.onOff(tf));
        end
        
        function t = getSelectedType(obj)
            t = get(obj.typePopupMenu, 'Value');
        end
        
        function l = getTypeList(obj)
            l = get(obj.typePopupMenu, 'Values');
        end
        
        function setTypeList(obj, names, values)
            set(obj.typePopupMenu, 'String', names);
            set(obj.typePopupMenu, 'Values', values);
        end
        
        function enableQlString(obj, tf)
            set(obj.qlStringField, 'Enable', appbox.onOff(tf));
        end
        
        function s = getQlString(obj)
            s = get(obj.qlStringField, 'String');
        end
        
        function requestQlStringFocus(obj)
            obj.update();
            uicontrol(obj.qlStringField);
        end
        
        function startSpinner(obj)
            obj.spinner.start();
        end
        
        function stopSpinner(obj)
            obj.spinner.stop();
        end
        
    end
    
end

