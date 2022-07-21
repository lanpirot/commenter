classdef enrich_models_container
    
    methods(Static)
        C = Constants(~);

        function en = BLOCKS_WITH_DOCU(~, model)
            handles = [find_system(model,'LookUnderMasks','on','FindAll','on','FollowLinks','on','Type','block'); find_system(model,'LookUnderMasks','on','FindAll','on','FollowLinks','on','Type','annotation')];

            en = struct.empty;

            for h=1:numel(handles)
                try
                    handle = handles(h);

                    docu_params = ["Description","MaskdisplayString","versinfo_string","Text","UserData"];

                    if strcmp(get_param(handle,'Type'),'annotation')
                        disp("")
                    end

                    contains_documentation = false;
                    for p=1:numel(docu_params)
                        param = docu_params(p);
                        try
                            next_value = get_param(handle,param);
                            if ~isempty(next_value) && ~strcmp(next_value,"")
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
            
            
            block.HierarchyDepth = count(block.Parent,'/');
            if ~strcmp(block.Parent,'')
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


        %here we count all BusCreator blocks and all Subsystems, that have
        %bus output ports (with a hierarchy)
        function en = NUM_BUS_CREATED(~, model)
            bs = find_system(model,'LookUnderMasks', 'on','FindAll','on','FollowLinks','on','BlockType','BusCreator');
            en = length(bs);

            subsystems = find_system(model,'LookUnderMasks', 'on','FindAll','on','FollowLinks','on','BlockType','SubSystem');

            for i = 1:length(subsystems)
                subsystem = subsystems(i);
                outports = find_system(subsystem,'SearchDepth',1,'BlockType','Outport');
                composite_ports = [];
                for j = 1:length(outports)
                    outport = outports(j);
                    if strcmp(get_param(outport,'IsComposite'),'on')
                        composite_ports = [composite_ports str2num(get_param(outport,'Port'))];
                    end
                end
                en = en + length(unique(composite_ports));
            end
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
        
        function en = CYCLOMATIC_COMP(~, model)
            metric_engine = slmetric.Engine();
            setAnalysisRoot(metric_engine, 'Root',  model);

            execute(metric_engine, 'mathworks.metrics.CyclomaticComplexity');
            en = getMetrics(metric_engine, 'mathworks.metrics.CyclomaticComplexity');
            en = en.Results;
            if isempty(en)
                en = "ERROR";
                return
            end
            en = en(1).AggregatedValue;
        end
        
        function en = NUM_SUBSYSTEMS(~, model)
            blocks = find_system(model,'LookUnderMasks', 'on','FindAll','on','FollowLinks','on','BlockType','SubSystem');
            en = length(blocks);
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

        function en = BUS_OUTPORT_ANALYSIS(json_model, model)
            global C
            if json_model.(C.NUM_BUS_CREATED) == 0
                en = struct.empty;
                return
            end
            en = struct.empty;
            bs = find_system(model,'regexp','on','LookUnderMasks', 'on','FindAll','on','FollowLinks','on','BlockType','SubSystem|BusCreator');
            for i = 1:length(bs)
                b = bs(i);
                outports = get_param(b,'PortHandles').Outport;
                for j = 1:length(outports)
                    o = outports(j);
                    hierarchy = get_param(o, 'SignalHierarchy');
                    count = enrich_models_container.signal_count(hierarchy);
                    if count == 0
                        continue
                    end
                    depth = enrich_models_container.bus_depth(hierarchy);
                    b_c = enrich_models_container.inner_busses(hierarchy);                    
                    en(end+1).(C.CONTAINED_SIGNALS) = count;
                    en(end).(C.SIGNAL_DEPTH) = depth;
                    en(end).(C.CONTAINED_BUSSES) = b_c;
                    en(end).(C.SUBSYSTEM_LINES) = enrich_models_container.NUM_LINES(1, get(getSimulinkBlockHandle(get(o,'Parent')),'Parent'), 1);
                end
            end
        end
        
        %is the port connected to a bus?
        function i_b = is_bus(hierarchy)
            i_b = 0;
            if isempty(hierarchy)
                return
            end
            if not(isempty(hierarchy.Children))
                i_b = 1;
            end
        end

        %how many levels deep, are busses nested?
        function max_depth = bus_depth(hierarchy)
            children = hierarchy.Children;
            max_depth = 0;
            for i = 1:length(children)
                child = children(i);
                %disp(child.SignalName)
                max_depth = max(max_depth, enrich_models_container.bus_depth(child) + 1);
            end
        end

        %how many busses are contained in the bus?
        function bc = inner_busses(hierarchy)
            bc = enrich_models_container.bus_count(hierarchy) - 1;
        end

        %how many busses are contained in a bus, counting the bus itself
        function b_c = bus_count(hierarchy)
            children = hierarchy.Children;
            b_c = enrich_models_container.is_bus(hierarchy);
            for i = 1:length(children)
                child = children(i);
                b_c = b_c + enrich_models_container.bus_count(child);
            end
        end

        %how many signals are contained in a bus?
        function s_c = signal_count(hierarchy)
            s_c = 0;
            if isempty(hierarchy)
                return
            end
            children = hierarchy.Children;
            
            for i = 1:length(children)
                child = children(i);
                if isempty(child.Children)
                    s_c = s_c + 1;
                else
                    s_c = s_c + enrich_models_container.signal_count(child);
                end
            end
        end


        function bsu = SIGNAL_USED_RATIO(json_model, model)
            global C
            bsu = struct.empty;
            if json_model.(C.NUM_BUS_CREATED) == 0
                en = struct.empty;
                return
            end
            subsystems = find_system(model,'LookUnderMasks','on','FindAll','on','FollowLinks','on','BlockType','SubSystem');
            

            delta = 0;
            for s = 1:length(subsystems)
                subsystem = subsystems(s);
                %'' ~= get_param(subsystem,'ReferenceBlock')
                %if this is a linked subsystem
                
                outer_inports = get_param(subsystem,'PortHandles').Inport;
                analyze_further = 0;
                for i = 1:length(outer_inports)
                    outer_inport = outer_inports(i);
                    incoming = enrich_models_container.signal_count_inport(get_param(outer_inport,'SignalHierarchy'));
                    if incoming > 1
                        analyze_further = 1;
                    end
                    bsu(end+1).incoming = incoming;
                    bsu(end).following = 0;          
                end

                inner_inports = find_system(subsystem,'LookUnderMasks','on','SearchDepth',1,'BlockType','Inport');
                if analyze_further
                    for i = 1:length(inner_inports)
                        inner_inport = inner_inports(i);
                        ports = get_param(inner_inport,'PortHandles').Outport;

                        which_one = delta + str2num(get_param(inner_inport,'Port'));
                        bsu(which_one).following = bsu(which_one).following + enrich_models_container.signal_count_inport(get_param(ports,'SignalHierarchy'));
                    end
                end
                delta = delta + length(outer_inports);
            end

            %clear single lines, we only want to know about bus-lines
            if ~isempty(bsu)
                bsu([bsu.incoming]<=1) = [];
            end
        end

        function s_c = signal_count_inport(hierarchy)
            s_c = 1;
            if isempty(hierarchy) || isempty(hierarchy.Children)
                return
            end
            s_c = 0;
            children = hierarchy.Children;

            for i = 1:length(children)
                child = children(i);
                if isempty(child.Children)
                    s_c = s_c + 1;
                else
                    s_c = s_c + enrich_models_container.signal_count_inport(child);
                end
            end
        end


    end
end