function main()
    import encoreui.app.*;

    uix.tracking('off');

    busy = appbox.BusyPresenter('Starting...');
    busy.go();
    deleteBusy = onCleanup(@()delete(busy));

    updater = appbox.GitHubUpdater();
    appLocation = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', '..');
    isUpdate = updater.checkForUpdates(encore.app.App.owner, encore.app.App.repo, ...
        struct('name', encore.app.App.name, 'version', encore.app.App.version, 'appLocation', appLocation));
    if isUpdate
        p = appbox.UpdatePresenter(updater);
        p.goWaitStop();
        info = p.result;
        if ~isempty(info)
            msg = 'The update is complete. You must run ''clear classes'' or restart MATLAB before Encore will launch again.';
            appbox.MessagePresenter(msg, 'Update Complete', 'OK').goWaitStop();
            disp(msg);
            return;
        end
    end

    addJavaJars({'encore-core.jar', 'UIExtrasComboBox.jar', 'UIExtrasTable.jar', 'UIExtrasTable2.jar', 'UIExtrasTree.jar', 'UIExtrasPropertyGrid.jar'});

    options = encoreui.app.Options.getDefault();
    session = Session(options);

    dataStoreService = DataStoreService(session);
    configurationService = ConfigurationService(session);

    presenter = encoreui.ui.presenters.MainPresenter(dataStoreService, configurationService);

    delete(busy);
    presenter.go();
end

function addJavaJars(jars)
    for i = 1:numel(jars)
        path = which(jars{i});
        if isempty(path)
            error(['Cannot find ' jars{i} ' on the matlab path']);
        end
        if ~any(strcmpi(javaclasspath, path))
            javaaddpath(path);
        end
    end
end
