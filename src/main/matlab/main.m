function main()
    busy = appbox.BusyPresenter('This may take a moment.', 'Starting...');
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
            appbox.MessagePresenter(msg, 'Update Complete', 'OK', [], [], 1).goWaitStop();
            disp(msg);
            return;
        end
    end

    presenter = encoreui.ui.presenters.MainPresenter();

    delete(busy);
    presenter.go();
end
