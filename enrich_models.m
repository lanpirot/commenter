function enrich_models(C)
    warning('off','all')
    format compact

    global C 
    en_fs = enrich_models_container;
    global hfs
    hfs = Helper_functions;

    en_tuples = {
        C.IS_LOADABLE,@en_fs.IS_LOADABLE,...
        C.BLOCKS_WITH_DOCU,@en_fs.BLOCKS_WITH_DOCU,...
        C.M_DESCRIPTION,@en_fs.DESCRIPTION,...
        C.NUM_LINES,@en_fs.NUM_LINES,...
        C.NUM_BLOCKS,@en_fs.NUM_BLOCKS,...
        C.SUBSYS_INFO,@en_fs.SUBSYS_INFO,...
        C.TUD,@en_fs.TUD,...
        C.CYCLOMATIC_COMP,@en_fs.CYCLOMATIC_COMP};

    %en_tuples = {
    %    C.IS_LOADABLE,@en_fs.IS_LOADABLE,...
    %    C.CYCLOMATIC_COMP,@en_fs.CYCLOMATIC_COMP};

    all_projects = jsondecode(fileread(C.all_models_json));


    for i = 1:2:length(en_tuples)
        en_tuple = [en_tuples(i), en_tuples(i+1)];
        all_projects = maybe_init(all_projects, en_tuple{1});
        all_projects = enrich(all_projects, en_tuple);
        hfs.saveit(all_projects, C.all_models_json);
        hfs.make_pretty(C.all_models_json);
    end
    fprintf("Model enrichment done.\n\n")
return

function all_projects = enrich(all_projects, en_tuple)
    global C
    new_field = en_tuple{1};

    for j = 1:length(all_projects)
        project_models = all_projects(j).(C.MODELS);
        project_path = all_projects(j).(C.PROJECT_PATH);
        for i = 1:length(project_models)


            model = project_models(i);
            warning('off','all');

            dont_analyze_models = [2718, 3705, 6150, 6151, 6807, 6808, 6809, 8839, 8931]; %opening these models causes environmenttal/global variables to get cleared. We skip them
            dont_analyze_cyclo_models = [242, 399, 817, 820, 898, 899, 958, 959, 960, 961, 962, 963, 965, 966, 1221, 1967, 1974, 2032, 2035, 2078, 2079, 2080, 2082, 2083, 2084, 2085, 2087, 2272, 2682, 2763, 2996, 3368, 3504, 3835, 3855, 4134, 4242, 4527, 4704, 4920, 5012, 5015, 5206, 5368, 5408, 5814, 5852, 6006, 6036, 6076, 6278, 6358, 6761, 6762, 6906, 6969, 6970, 6979, 7173, 7373, 7424, 7574, 7579, 8113, 8115, 8116, 8855, 8856, 9006, 9070]; %while analyzing them, cyclomatic complexity might cause segmentation faults and kill the script. We skip them

            if (strcmp(en_tuple{1}, C.CYCLOMATIC_COMP) && ismember(model.m_num, dont_analyze_cyclo_models)) || ismember(model.m_num, dont_analyze_models)
                continue
            end

            

            
            fprintf("Enriching model %i with %s\n", model.(C.M_NUM), new_field)
            all_projects(j).(C.MODELS)(i).(new_field) = en_template(en_tuple, all_projects(j), model);

            fprintf("Done with model %i.\n", model.(C.M_NUM))
        end
    end
return

function en = en_template(en_tuple, project, model)
    global C
    en = C.NO_TODO;
    field = en_tuple{1};
    %if not openable: don't bother analyzing
    if strcmp(model.(C.IS_LOADABLE), C.ERROR) && ~strcmp(C.FORCE_OVERWRITE, C.IS_LOADABLE)
        return
    end
    
    mf = model.(field);
    if ~ischar(mf) && ~isa(mf,'string')
        mf = "";
    end

    if ~strcmp(mf,C.TODO) && strcmp(C.OVERWRITE,C.NO) && ~strcmp(field, C.FORCE_OVERWRITE)
        return
    end
    %otherwise actually analyze and enrich
    
    try
        load_system(project.(C.PROJECT_PATH)+C.dir_separator+model.(C.REL_PROJ_PATH));
        model_name_no_ending = gcs;
        en_function = en_tuple{2};
        en = en_function(model, model_name_no_ending);
        if ~isa(en, 'struct') && ~isa(en,'float')
            en = string(en);
        elseif isa(en, 'struct')
            for i = 1:numel(en)
                try

                    u = en(i).UserData;
                    if (isa(u,'char') && ~isempty(u)) || (isa(u,'string') && ~u=="") || ~strcmp(u.content,"")
                        jsonencode(u);
                    else
                        en(i).UserData = "";
                    end
                catch
                    en(i).UserData = "";
                end
            end
        end
        close_system(model_name_no_ending)
    catch ME
        try
            disp(ME)
            en = C.ERROR;
            close_system(model_name_no_ending)
        catch ME
            disp(ME)
        end
    end
return

function all_projects = maybe_init(all_projects, new_field)
    global C
    model_fields = fields(all_projects(1).(C.MODELS)(1));
    if any(strcmp(model_fields, new_field))
        return
    end

    for j = 1:length(all_projects)
        for m = 1:length(all_projects(j).(C.MODELS))
            all_projects(j).(C.MODELS)(m).(new_field) = C.TODO;
        end
    end
return