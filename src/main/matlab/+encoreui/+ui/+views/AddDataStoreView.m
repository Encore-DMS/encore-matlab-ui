classdef AddDataStoreView < appbox.View

    events
        Add
        Cancel
    end

    properties (Access = private)
        hostField
        usernameField
        passwordField
        spinner
        addButton
        cancelButton
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'Add Data Store', ...
                'Position', screenCenter(hpix(330/11), vpix(139/16)), ...
                'Resize', 'off');

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            storeLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', storeLayout, ...
                'String', 'Host:');
            Label( ...
                'Parent', storeLayout, ...
                'String', 'Username:');
            Label( ...
                'Parent', storeLayout, ...
                'String', 'Password:');
            obj.hostField = uicontrol( ...
                'Parent', storeLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.usernameField = uicontrol( ...
                'Parent', storeLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.passwordField = PasswordField( ...
                'Parent', storeLayout);
            set(storeLayout, ...
                'Widths', [hpix(65/11) -1], ...
                'Heights', [vpix(23/16) vpix(23/16) vpix(23/16)]);

            % Add/Cancel controls.
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
            obj.addButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Add', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Add'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [hpix(16/11) -1 hpix(75/11) hpix(75/11)]);

            set(mainLayout, 'Heights', [-1 vpix(23/16)]);

            % Set clone button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.addButton);
            end
        end
        
        function enableAdd(obj, tf)
            set(obj.addButton, 'Enable', appbox.onOff(tf));
        end
        
        function tf = getEnableAdd(obj)
            tf = appbox.onOff(get(obj.addButton, 'Enable'));
        end
        
        function enableCancel(obj, tf)
            set(obj.cancelButton, 'Enable', appbox.onOff(tf));
        end
        
        function enableHost(obj, tf)
            set(obj.hostField, 'Enable', appbox.onOff(tf));
        end

        function u = getHost(obj)
            u = get(obj.hostField, 'String');
        end

        function requestHostFocus(obj)
            obj.update();
            uicontrol(obj.hostField);
        end
        
        function enableUsername(obj, tf)
            set(obj.usernameField, 'Enable', appbox.onOff(tf));
        end

        function u = getUsername(obj)
            u = get(obj.usernameField, 'String');
        end
        
        function enablePassword(obj, tf)
            set(obj.passwordField, 'Enable', appbox.onOff(tf));
        end

        function p = getPassword(obj)
            p = get(obj.passwordField, 'String');
        end
        
        function startSpinner(obj)
            obj.spinner.start();
        end
        
        function stopSpinner(obj)
            obj.spinner.stop();
        end

    end

end
