classdef AddDataStorePresenter < appbox.Presenter

    properties (Access = private)
        log
        dataStoreService
    end

    methods

        function obj = AddDataStorePresenter(dataStoreService, view)
            if nargin < 2
                view = encoreui.ui.views.AddDataStoreView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.dataStoreService = dataStoreService;
        end

    end

    methods (Access = protected)

        function didGo(obj)
            obj.view.requestUrlFocus();
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Add', @obj.onViewSelectedAdd);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedAdd();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedAdd(obj, ~, ~)
            obj.view.update();

            url = obj.view.getUrl();
            user = obj.view.getUser();
            password = obj.view.getPassword();
            try
                store = obj.dataStoreService.addDataStore(url, user, password);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            obj.result = store;
            obj.stop();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end

    end

end
