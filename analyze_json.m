function analyze_json()
    %C = Helper_functions.create_constants(1, 2820);
    json_file = "all_models.json";
    projects = jsondecode(fileread(json_file));
    C = Helper_functions.create_constants(1, length(projects));
    
    model_descriptions = struct_scheme();
    annotations = struct_scheme();
    block_descriptions = struct_scheme();
    doc_blocks = struct_scheme();
    %MaskDisplayString
    %versinfo_string

    for i=1:numel(projects)
        for j=1:numel(projects(i).(C.MODELS))
            model = projects(i).(C.MODELS)(j);
            if ~strcmp(model.(C.M_DESCRIPTION),"") && ~strcmp(model.(C.M_DESCRIPTION),C.NO_TODO)
                model_descriptions(end+1) = parse_block(model.absolute_path, "", "", model.(C.M_DESCRIPTION), "");
            end


            if isa(model.(C.BLOCKS_WITH_DOCU),'char')
                continue
            end
            for k=1:numel(model.(C.BLOCKS_WITH_DOCU))
                block = model.(C.BLOCKS_WITH_DOCU)(k);
                if strcmp(block.Type,'annotation')
                    annotations(end+1) = parse_block(model.absolute_path, block.Parent, "", block.Text, "");
                elseif ~strcmp(block.Description,"")
                    block_descriptions(end+1) = parse_block(model.absolute_path, block.Parent, block.Name, block.Description, "");
                elseif strcmp(block.MaskType,'DocBlock')
                    ud = block.UserData;
                    if isempty(ud)
                        continue
                    elseif isa(ud,'char') || isa(ud,'string')
                        content = ud;
                    else
                        content = ud.content;
                    end
                    doc_blocks(end+1) = parse_block(model.absolute_path, block.Parent, block.Name, content, ud.format);
                end
            end
        end
    end
    

    all_docu_types = [struct('name','annotations','struct_list',annotations),struct('name','model_descriptions','struct_list',model_descriptions),struct('name','block_descriptions','struct_list',block_descriptions),struct('name','doc_blocks','struct_list',doc_blocks)];
    present(all_docu_types)
    %export_to_csv(all_docu_types)
end

function present(all_docu_types)
    for i = 1:numel(all_docu_types)
        struct = all_docu_types(i);
        name = struct.name;
        docu_list = struct.struct_list;
        fprintf("We found %i(%i) %s.\n", my_unique(docu_list), numel(docu_list), name)
    end
end

function rt = my_unique(docu_list)
    texts_only = [];
    for i = 1:numel(docu_list)
        texts_only = [texts_only ; string(docu_list(i).Text)];
    end
    rt = length(unique(texts_only));
end

function scheme = struct_scheme()
    scheme = struct('Path',{},'Parent',{},'Name',{},'Text',{},'Format',{});
end

function export_to_csv(all_docu_types)
    for i=1:numel(all_docu_types)
        struct = all_docu_types(i);
        name = struct.name;
        table = struct2table(struct.struct_list);
        writetable(table,name+".csv",'QuoteStrings',true)
    end
end

function block_params = parse_block(path, parent, name, text, format)
    %FORMAT
    %model_path,parent_path,name,DocuText
    block_params = struct;
    block_params.Path = path;
    block_params.Parent = parent;
    block_params.Name = name;
    block_params.Text = text;
    block_params.Format = format;
end