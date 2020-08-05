function write_partial_motl(rootdir,o,splitmotl)
%% write_partial_motl
% A function for writing partial motivelists during subtomogram alignment. 
%
% WW 05-2018


%% Write partial motl


% Initialize file
filename = [rootdir,o.tempdir,'splitmotl_',num2str(o.procnum),'.csv'];
fid = fopen(filename,'w');
        
% Number of motls        
n_motl = numel(splitmotl);

% Write each motl
for i = 1:n_motl

    % Format output
    output = zeros(1,10);
    output(1) = splitmotl(i).subtomo_num;
    output(2) = splitmotl(i).halfset;
    output(3) = splitmotl(i).score;
    output(4) = splitmotl(i).x_shift;
    output(5) = splitmotl(i).y_shift;
    output(6) = splitmotl(i).z_shift;
    output(7) = splitmotl(i).phi;
    output(8) = splitmotl(i).psi;
    output(9) = splitmotl(i).the;
    output(10) = splitmotl(i).class;

    % Write output (subtomo_num,score,x-shift,y-shift,z-shift,phi,psi,the,class)
    fprintf(fid,'%d,%d,%0.8f,%0.8f,%0.8f,%0.8f,%0.8f,%0.8f,%0.8f,%d\n',output);
        
end        

% Close file
fclose(fid);
        


        
    
    

