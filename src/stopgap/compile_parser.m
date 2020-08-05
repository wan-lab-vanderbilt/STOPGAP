function compile_parser()

% Clear workspace
clear all
close all

% Get STOPGAPHOME
[~,stopgaphome] = system('echo $STOPGAPHOME');

% Compile
mcc('-mv', '-R', 'nojvm', '-R', '-nodisplay', '-R' ,'-singleCompThread', '-R', '-nosplash', 'stopgap_parser.m', '-d', [stopgaphome(1:end-1),'/lib/'])
