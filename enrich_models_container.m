classdef enrich_models_container
    
    methods(Static)
        C = Constants(~);

        function en = BLOCKS_WITH_DOCU(~, model)
            handles = [find_system(model,'LookUnderMasks','on','FindAll','on','FollowLinks','on','Type','block'); find_system(model,'LookUnderMasks','on','FindAll','on','FollowLinks','on','Type','annotation')];

            en = struct.empty;

            for h=1:numel(handles)
                try
                    handle = handles(h);

                    docu_params = ["Description", "MaskdisplayString", "versinfo_string", "Text", "UserData"];

                    contains_documentation = false;
                    for p=1:numel(docu_params)
                        param = docu_params(p);
                        try
                            next_value = get_param(handle, param);
                            if ~isempty(next_value) && ~strcmp(next_value, "")
                                contains_documentation = true;
                                break
                            end
                        catch
                        end
                    end
                    if contains_documentation
                        if isempty(en)
                            en = enrich_models_container.all_info_of_block(handle);
                        else
                            en(end+1) = enrich_models_container.all_info_of_block(handle);
                        end
                    end
                catch
                end
            end
        end

        function en = DESCRIPTION(~, model)
            en = get_param(model,'Description');
        end

        %returns all (deemed useful) information of a given block
        %other possible parameters may be in:
        %params = get_param(block.Handle,'DialogParameters');
        %params = get_param(block.Handle,'IntrinsicDialogParameters');
        %params = get_param(block.Handle,'ObjectParameters');
        %
        %lots of parameters in Masks not yet included
        function block = all_info_of_block(handle)
            global C
            block = struct;
            block.Handle = handle;
            param_list = C.param_list;
        
            for p=1:numel(param_list)
                param = param_list(p);
                try
                    next_value = get_param(block.Handle,param);
                    if isempty(next_value) || strcmp(next_value,'')
                        block.(param) = "";
                    else
                        block.(param) = next_value;
                        continue
                    end
                    if ~strcmp(next_value.content,'')
                        block.(param) = next_value.content;
                    end
                catch
                    block.(param) = "";
                end
            end
            
            
            block.HierarchyDepth = count(block.Parent, '/');
            if ~strcmp(block.Parent, '')
                block.HierarchyDepth = block.HierarchyDepth + 1;
            end
            try
                ullr = enrich_models_container.get_position(block.Handle);
                block.UL = ullr.ul;
                block.LR = ullr.lr;
            catch
            end
        end

        %returns position of upper left (ul) and lower right (lr)
        %also relative upper left and lower right of first connected block (if any)
        function posis = get_position(handle)
            position = get_param(handle,'Position');
            posis = struct;
            posis.ul = [position(1) position(2)];
            posis.lr = [position(3) position(4)];
        end
        
        function en = NUM_BLOCKS(~, model)
            blocks = find_system(model,'LookUnderMasks', 'on','FindAll','on','FollowLinks','on','type','block');
            en = length(blocks);
        end

        function en = NUM_LINES(~, system, depthdepth)
            if exist('depthdepth','var')
                lineHandles = find_system(system,'FindAll','on','SearchDepth',string(depthdepth),'type','line');
            else
                lineHandles = find_system(system,'LookUnderMasks', 'on','FindAll','on','FollowLinks','on','type','line');
            end

            lineDim = size(lineHandles);
            lines = lineDim(1,1);

            % If a block has multiple output connections over the same port
            % (i.e. branches), there will be a redundant "line" containing all
            % destination blocks (in a cell), exclude these from the count
            count = 0;
            for k = 1:lines
                % Get destination block for current line
                dst = get_param(lineHandles(k),'DstBlockHandle');

                if any(dst==-1) || ismember(-1, dst)
                    continue
                end

                % May return a cell if there are multiple destinations
                dst_names = get_param(dst,'Name');

                % Only count the individual lines
                if ~iscell(dst_names)
                    count = count + 1;
                end
            end
            en = count;
        end

        function en = SUBSYS_INFO(~, model)
            en = struct;
            depths = [];
            subsystems = find_system(model,'LookUnderMasks','on','FindAll','on','FollowLinks','on','BlockType','SubSystem');
            for i=1:length(subsystems)
                subsystem = subsystems(i);
                depths(end + 1) = count(get_param(subsystem, "Parent"), '/') + 1;
            end
            en.SUB_HIST = histcounts(depths);
            
            max_depth = length(en.SUB_HIST);
            num_el_depths = zeros(1,max_depth);
            for i=1:length(subsystems)
                subsystem = subsystems(i);
                curr_depth = count(get_param(subsystem, "Parent"), '/') + 1;
                num_el_depths(curr_depth) = num_el_depths(curr_depth) + length(find_system(subsystem,'LookUnderMasks','on','FindAll','on','FollowLinks','on','SearchDepth',1));
            end
            en.NUM_EL_DEPTHS = num_el_depths;
            en.SUB_NUM = length(subsystems);
        end
        
        function en = CYCLOMATIC_COMP(~, model)
            metric_engine = slmetric.Engine();
            setAnalysisRoot(metric_engine, 'Root',  model);

            execute(metric_engine, 'mathworks.metrics.CyclomaticComplexity');
            en = getMetrics(metric_engine, 'mathworks.metrics.CyclomaticComplexity');
            status = en.Status;
            en = en.Results;
            if isempty(en)
                en = "ERROR" + string(status);
                return
            end
            en = en(1).AggregatedValue;
        end

        function en = TUD(~, model)
            CreationDate = get_param(model, 'Created');
            LastChangeDate = get_param(model, 'LastModifiedDate');

            try
                inputFormat = 'eee MMM dd HH:mm:ss yyyy';
                CreationDate = datetime(CreationDate,'InputFormat', inputFormat);
            catch ME
                try
                    inputFormat = 'MMM dd HH:mm:ss yyyy';
                    CreationDate = datetime(CreationDate,'InputFormat', inputFormat);
                catch ME
                    inputFormat = 'M/d/yy';
                    CreationDate = datetime(CreationDate,'InputFormat', inputFormat);
                end
            end
            try
                inputFormat = 'eee MMM dd HH:mm:ss yyyy';
                LastChangeDate = datetime(LastChangeDate,'InputFormat', inputFormat);
            catch ME
                try
                    inputFormat = 'MMM dd HH:mm:ss yyyy';
                    LastChangeDate = datetime(LastChangeDate,'InputFormat', inputFormat);
                catch ME
                    inputFormat = 'M/d/yy';
                    LastChangeDate = datetime(LastChangeDate,'InputFormat', inputFormat);
                end
            end

            en = days(LastChangeDate - CreationDate);
        end        

        function en = IS_LOADABLE(~, ~)
            global C
            en = C.YES;
        end

    end
end