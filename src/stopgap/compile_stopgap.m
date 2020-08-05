function compile_stopgap()

% Clear workspace
clear all
close all

% Compile
mcc -mv -R nojvm -R -nodisplay -R -singleCompThread -R -nosplash stopgap.m -d /fs/pool/pool-plitzko/will_wan/software/stopgap/0.7.1/module/lib/
1