function sg_toolbox()
%% sg_toolbox
% A standalone compiled version of the STOPGAP toolbox. This allows users
% to access toolbox functions without a MATLAB license. 
%
% This is borrows ideas from Dyanmo's console. 
%
% WW 05-2024


%% Initialize

fprintf('Loading standalone STOPGAP toolbox!!! \n\n');
fprintf('    Notes on the standalone sg_toolbox:\n');
fprintf('    -----------------------------------\n\n');

fprintf('    * Type in sg_toolbox commands to run\n');
fprintf('    * Like in MATLAB, supress output by ending commands with a ";"\n');
fprintf('    * You can use "whos" to list current variables\n');
fprintf('    * Starting a command with "!" will pass to Linux shell\n');
fprintf('    * Type "exit" to exit the STOPGAP toolbox\n\n');


%% Start interactive console

% Parameter to exit interactive console
end_console = false;

while ~end_console
    % Print console line
    fprintf('sg_toolbox > ');

    % Get console input
    console_input = input(' ','s'); 
    
    
    % Check for exit
    if any(strcmpi(console_input,{'exit','quit'}))
        end_console = true;
        continue
    end

    % Check for system input
    if strcmp(console_input(1),'!')
        
        % Run command
        disp('Passing command to system...');
        [status,report]=system(console_input(2:end));
        
        % Catch output
        if status~=0
            fprintf('SYSTEM: error code %d\n',status);
        end        
        disp(report);
        
        continue
    end

    % Run matlab input
    try
        % Run console input
        evalin('base',console_input);
%         [report]=evalc(console_input);
%         if iscell(report)
%             for lc=1:length(report)
%                 disp(report{lc});
%             end
%         else
%             disp(report);
%         end
        
    catch
        
        % Return error
        fprintf('MATLAB error: \n');
        fprintf(lasterr); %#ok<LERR>
        fprintf('\n\n');

    end
    
end

fprintf('Exiting standalone STOPGAP toolbox!!! \n\n');


