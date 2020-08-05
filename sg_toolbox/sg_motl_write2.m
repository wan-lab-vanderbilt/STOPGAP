function sg_motl_write2(motl_name,motl,skip_header)
%% sg_motl_write2
% Take a style-2 motivelist struct and write out.
%
% WW 06-2019

% rootdir = './';
% motl_name = 'test_motl.star';

%% Check check
if nargin == 2
    skip_header = false;
end

%% Determine formating

% Parse fields
fields = fieldnames(motl);
n_motls = numel(motl.motl_idx);

% Get field types
motl_fields = sg_get_motl_fields;
n_fields = size(motl_fields,1);
if size(fields,1) ~= n_fields
    error('ACHTUNG!!! Input struct has incorrect number of fields!!!');
end

% Check sorting
motl = orderfields(motl,motl_fields(:,1));
motl = sg_sort_motl2(motl);


% Generate formatting string
fmt_cell = cell(n_fields,1);
for i = 1:n_fields
    switch(motl_fields{i,3})
        case 'str'
            ml = max(cellfun(@(x) numel(x), motl.(motl_fields{i,1})));
            fmt_cell{i} = ['%-',num2str(ml),'c'];
        case 'int'
            md = ceil(log10(single(max(abs(motl.(motl_fields{i,1})))+1)));
            fmt_cell{i} = ['%',num2str(md),'d'];
        case 'float'
            md = ceil(log10(max(abs(motl.(motl_fields{i,1})))+1));
            fmt_cell{i} = ['%',num2str(md+6),'.4f'];
        case 'boo'
            fmt_cell{i} = '%1d';
    end
end


%% Write output
disp(['Writing ',motl_name,'...']);

% Open file
fid = fopen(motl_name,'w');

% Write header info
if ~skip_header    
    fprintf(fid,'\n%s\n\n','data_stopgap_motivelist');
    fprintf(fid,'%s\n','loop_');
    for i = 1:n_fields
        fprintf(fid,'%s\n',['_',motl_fields{i,1}]);
    end
    fprintf(fid,'%s\n','');
end


% Write data

for i = 1:n_motls
    
    for j = 1:n_fields
        
        % Parse formating
        switch j
            case 1
                fmt = [' ',fmt_cell{j},];
            case n_fields
                fmt = [' ',fmt_cell{j},'\n'];
            otherwise
                fmt = [' ',fmt_cell{j},' '];
        end
        
        % Parse data
        switch motl_fields{j,3}
            case 'str'
                val = motl.(motl_fields{j,1}){i};
            otherwise
                val = motl.(motl_fields{j,1})(i);
        end
        
        % Print data
        fprintf(fid,fmt,val);
        
    end
        
end



fclose(fid);


disp([motl_name,' written!!!1!']);








