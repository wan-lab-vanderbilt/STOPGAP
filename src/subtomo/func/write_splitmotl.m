function sm = write_splitmotl(p,o,idx,sm,task,motl,ali)
%% write_splitmotl
% A function for initializing and writing of split motivelist during
% parallel subtomogram alignment.
%
% WW 06-2019

%% Write splitmotl

switch task
    
    case 'init'
        
%         %%%%% Initialize motivelist %%%%%
%         
%         % Determine indices
%         motl_idx = ismember(o.allmotl.motl_idx,o.ali_motl);
% 
%         % Parse new motivelist
%         sm.motl = parse_motl(o.allmotl,motl_idx);
%         
%         % Writing index
%         sm.idx = 1;
        
        
        
        %%%%% Prepare formatting %%%%%
        
        % Get field types
        sm.motl_fields = sg_get_motl_fields;
        sm.n_fields = size(sm.motl_fields,1);
        
        % Generate formatting string
        sm.fmt_cell = cell(sm.n_fields,1);
        for i = 1:sm.n_fields
            switch(sm.motl_fields{i,3})
                case 'str'
                    ml = max(cellfun(@(x) numel(x), o.allmotl.(sm.motl_fields{i,1})));
                    sm.fmt_cell{i} = ['%-',num2str(ml),'c'];
                case 'int'
                    md = ceil(log10(single(max(abs(o.allmotl.(sm.motl_fields{i,1})))+1)));
                    sm.fmt_cell{i} = ['%',num2str(md),'d'];
                case 'float'
                    md = ceil(log10(max(abs(o.allmotl.(sm.motl_fields{i,1})))+1));
                    sm.fmt_cell{i} = ['%',num2str(md+6),'.4f'];
                case 'boo'
                    sm.fmt_cell{i} = '%1d';
            end
        end
        
        
        
        %%%%% Initialize output writer %%%%%
        
        % Open file
        sm_name = [o.tempdir,'/splitmotl_',num2str(o.procnum),'.temp'];
        sm.fid = fopen([p(idx).rootdir,'/',sm_name],'w');
        
        
        
        
    case 'write'                
        
        % Number of motl entries
        n_entry = size(ali,2);

        % Loop through entries
        for i = 1:n_entry

            %%%%% Parse ali struct %%%%%
                        
            % Find top score
            [~,max_idx] = max([ali(:,i).score]);

            % Fill fields
            motl.x_shift = ali(max_idx,i).new_shift(1);
            motl.y_shift = ali(max_idx,i).new_shift(2);
            motl.z_shift = ali(max_idx,i).new_shift(3);
            motl.phi = ali(max_idx,i).phi;
            motl.psi = ali(max_idx,i).psi;
            motl.the = ali(max_idx,i).the;
            motl.score = ali(max_idx,i).score;
            motl.class = ali(max_idx,i).class;
            
            
            
            %%%%% Write output %%%%%
            
            % Loop through fields
            for j = 1:sm.n_fields
        
                % Parse formating
                switch j
                    case 1
                        fmt = [' ',sm.fmt_cell{j},];
                    case sm.n_fields
                        fmt = [' ',sm.fmt_cell{j},'\n'];
                    otherwise
                        fmt = [' ',sm.fmt_cell{j},' '];
                end

                % Parse data
                switch sm.motl_fields{j,3}
                    case 'str'
                        val = motl.(sm.motl_fields{j,1}){1};
                    otherwise
                        val = motl.(sm.motl_fields{j,1});
                end

                % Print data
                fprintf(sm.fid,fmt,val);

            end
            
%             % Increment counter
%             sm.idx = sm.idx + 1;

        end
        
        
    case 'close'
        
        % Finished writing
        fclose(sm.fid);
        
        % Rename file
        sm_name1 = [o.tempdir,'/splitmotl_',num2str(o.procnum),'.temp'];
        sm_name2 = [o.tempdir,'/splitmotl_',num2str(o.procnum),'.star'];
        system(['mv ',p(idx).rootdir,'/',sm_name1,' ',p(idx).rootdir,'/',sm_name2]);
        
end




