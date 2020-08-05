function sg_motl_write(motl_name,motl)
%% sg_motl_write
%
% WW 05-2018

% rootdir = './';
% motl_name = 'test_motl.star';


%% Determine formating

% Parse fields
fields = fieldnames(motl);
n_motls = numel(motl);

% Get field types
motl_fields = sg_get_motl_fields;
n_fields = size(motl_fields,1);
if size(fields,1) ~= n_fields
    error('ACHTUNG!!! Input struct has incorrect number of fields!!!');
end

% Check sorting
motl = orderfields(motl,motl_fields(:,1));
motl = sort_motl(motl);

% Convert data to cell
data_cell = struct2cell(motl);

% Generate formatting string
fmt_cell = cell(n_fields,1);
for i = 1:n_fields
    switch(motl_fields{i,3})
        case 'str'
            ml = max(cellfun(@(x) numel(x), data_cell(i,:)));
            fmt_cell{i} = [' %-',num2str(ml),'c '];
        case 'int'
            md = ceil(log10(double(max(abs([data_cell{i,:}]))+1)));
            fmt_cell{i} = ['% ',num2str(md+1),'d '];
        case 'float'
            md = ceil(log10(max(abs([data_cell{i,:}]))+1));
            fmt_cell{i} = ['% ',num2str(md+6),'.4f '];
        case 'boo'
            fmt_cell{i} = '% 1d ';
    end
end
fmt = [fmt_cell{:}];
fmt = fmt(1:end-1);


%% Write output
disp(['Writing ',motl_name,'...']);

% Open file
fid = fopen(motl_name,'w');

% Write header info
fprintf(fid,'\n%s\n\n','data_stopgap_motivelist');
fprintf(fid,'%s\n','loop_');
for i = 1:n_fields
    fprintf(fid,'%s\n',['_',motl_fields{i,1}]);
end


% Write data
for i = 1:n_motls
    fprintf(fid,['\n',fmt],data_cell{:,i});
end
fprintf(fid,'%s\n','');


fclose(fid);


disp([motl_name,' written!!!1!']);








