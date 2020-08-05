function stopgap_parser(task,varargin)
%% stopgap_parser
% Top level function for STOPGAP parsers of each task.
%
% WW 06-2019

%% Send to parser

switch task
    
    % Subtomogram averaging/alignment
    case 'subtomo'
        disp('Parsing subtomogram alignment/averaging parameters...');
        subtomo_parser(varargin{:});
        
    case 'temp_match'
        disp('Parsing template matching parameters...');
        tm_parser(varargin{:});
        
    case 'pca'
        disp('Parsing PCA parameters...');
        pca_parser(varargin{:});
        
    case 'vmap'
        disp('Parsing variance map parameters...');
        stopgap_vmap_parser(varargin{:});
        
    otherwise
        error('ACHTUNG!!! Invalid task!!!');
        
        
end


end

