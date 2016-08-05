classdef OptionsView < appbox.View
    
    events
        SelectedNode
        Save
        Cancel
    end        
    
    properties (Access = private)
        masterList
        detailCardPanel
        generalCard
        saveButton
        cancelButton
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Options', ...
                'Position', screenCenter(hpix(500/11), vpix(300/16)));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            optionsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);

            masterLayout = uix.VBox( ...
                'Parent', optionsLayout);

            obj.masterList = uicontrol( ...
                'Parent', masterLayout, ...
                'Style', 'list', ...
                'String', {'General'}, ...
                'Callback', @(h,d)notify(obj, 'SelectedNode'));

            detailLayout = uix.VBox( ...
                'Parent', optionsLayout, ...
                'Spacing', 7);

            obj.detailCardPanel = uix.CardPanel( ...
                'Parent', detailLayout);
            
            % General card.
            generalGrid = uix.Grid( ...
                'Parent', obj.detailCardPanel, ...
                'Spacing', 7);
            
            set(obj.detailCardPanel, 'Selection', 1);

            javacomponent('javax.swing.JSeparator', [], detailLayout);

            set(detailLayout, 'Heights', [-1 1]);

            set(optionsLayout, 'Widths', [hpix(120/11) -1]);

            % Save/Default/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
            obj.saveButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Save', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Save'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 hpix(75/11) hpix(75/11)]);

            set(mainLayout, 'Heights', [-1 vpix(23/16)]);

            % Set OK button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.saveButton);
            end
        end
        
        function i = getSelectedNode(obj)
            i = get(obj.masterList, 'Value');
        end

        function setCardSelection(obj, index)
            set(obj.detailCardPanel, 'Selection', index);
        end
        
    end
    
end

