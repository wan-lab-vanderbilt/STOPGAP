function compile_extract()

% Clear workspace
clear all
close all


% Compile
mcc -mv -R nojvm -R -nodisplay -R -singleCompThread -R -nosplash stopgap_extract.m -d /fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/software/stopgap/0.7.0/module/lib/