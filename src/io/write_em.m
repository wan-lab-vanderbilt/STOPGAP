function write_em(rootdir,name,data)
%% write_em
% A function to write a .em file and verify that it was properly written by
% trying to read it.
%
% WW 11-2017

%% Write 

tom_emwrite([rootdir,'/',name],data);
% Check check!
c=0;
while c == 0
    try
        tom_emread([rootdir,'/',name]); % If this fails, catch command is run
        c = 1; % While-loop is exited if the emread works
    catch
        tom_emwrite([rootdir,'/',name],data);
    end
end