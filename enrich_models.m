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
        C.DESCRIPTION,@en_fs.DESCRIPTION};
        %C.NUM_LINES,@en_fs.NUM_LINES,...    
        %C.NUM_BLOCKS,@en_fs.NUM_BLOCKS,...
        %C.NUM_SUBSYSTEMS,@en_fs.NUM_SUBSYSTEMS};

    all_info = jsondecode(fileread(C.all_models_json));


    all_projects = all_info.(C.PROJECTS);

    for i = 1:2:length(en_tuples)
        en_tuple = [en_tuples(i), en_tuples(i+1)];
        all_projects = maybe_init(all_projects, en_tuple{1});
        all_projects = enrich(all_projects, en_tuple);
        all_info.(C.PROJECTS) = all_projects;
        hfs.saveit(all_info, C.all_models_json)
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
            
            fprintf("Enriching model %i with %s\n", model.(C.M_NUM), new_field)
            all_projects(j).(C.MODELS)(i).(new_field) = en_template(en_tuple, all_projects(j), model);



            %remove for speed
            Helper_functions.saveit(all_projects, C.all_models_json)

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