classdef App < handle

    methods (Static)

        function n = name()
            n = 'Encore';
        end

        function d = description()
            d = 'Data Management System';
        end

        function v = version()
            v = '1.0.0.0'; % i.e. 1.0-a
        end

        function o = owner()
            o = 'Encore-DMS';
        end

        function u = documentationUrl()
            u = encoreui.app.App.getResource('docs', 'README.html');
        end

        function u = userGroupUrl()
            u = 'https://groups.google.com/forum/#!forum/symphony-das';
        end

        function p = getResource(varargin)
            resourcesPath = fullfile(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))), 'resources');
            p = fullfile(resourcesPath, varargin{:});
        end

    end

end
