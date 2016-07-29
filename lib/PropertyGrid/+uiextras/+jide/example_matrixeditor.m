% Demonstrates how to use the matrix editor.
%
% See also: MatrixEditor

% Copyright 2010 Levente Hunyadi
function example_matrixeditor

fig = figure( ...
    'MenuBar', 'none', ...
    'Name', 'Matrix editor demo - Copyright 2010 Levente Hunyadi', ...
    'NumberTitle', 'off', ...
    'Toolbar', 'none');
editor = uiextras.jide.MatrixEditor(fig, ...
    'Item', [1,2,3,4;5,6,7,8;9,10,11,12], ...
    'Type', uiextras.jide.PropertyType('denserealdouble','matrix'));
uiwait(fig);
disp(editor.Item);
