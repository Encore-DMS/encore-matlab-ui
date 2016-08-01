classdef CloneDataStoreView < appbox.View
    
    events
        Clone
        Cancel
    end
    
    properties (Access = private)
        cloneButton
        cancelButton
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Clone Data Store', ...
                'Position', screenCenter(hpix(400/11), vpix(250/16)));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);
            
            cloneLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            % Clone/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.cloneButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Clone', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Clone'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 hpix(75/11) hpix(75/11)]);

            set(mainLayout, 'Heights', [-1 vpix(23/16)]);

            % Set clone button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.cloneButton);
            end
        end
        
    end
    
end

