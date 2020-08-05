function compile_watcher()

% Clear workspace
clear all
close all

% Get STOPGAPHOME
[~,stopgaphome] = system('echo $STOPGAPHOME');

% Compile
mcc('-mv', '-R', 'nojvm', '-R', '-nodisplay', '-R' ,'-singleCompThread', '-R', '-nosplash', 'stopgap_watcher.m', '-d', [stopgaphome(1:end-1),'/lib/'])

