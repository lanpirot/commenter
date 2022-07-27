function enrich_projects(C)
    warning('off','all')
    format compact

    global C
    en_fs = enrich_projects_container;
    global hfs
    hfs = Helper_functions;
    en_tuples = {
        C.NUM_MODELS, @en_fs.NUM_MODELS};
        %C.PROJECT_LENGTH, @en_fs.PROJECT_LENGTH};%,...
        %C.PROJECT_NAME_DUPLICATES, @en_fs.PROJECT_NAME_DUPLICATES};

    all_projects = jsondecode(fileread(C.all_models_json));

    for i = 1:2:length(en_tuples)
        en_tuple = [en_tuples(i), en_tuples(i+1)];
        all_projects = maybe_init(all_projects, en_tuple{1});
        all_projects = enrich(all_projects, en_tuple);
    end

    hfs.saveit(all_projects, C.all_models_json)
    hfs.make_pretty(C.all_models_json)
    fprintf("Project enrichment done.\n\n")
return

function all_projects = enrich(all_projects, en_tuple)
    global C
    new_field = en_tuple{1};

    for j = 1:length(all_projects)
        project = all_projects(j);
        
        new_entry = en_template(en_tuple, project);
        if strcmp(new_entry, C.NO_TODO)
            continue
        end
        
        all_projects(j).(new_field) = new_entry;
    end
return

function en = en_template(en_tuple, project)
    global C
    field = en_tuple{1};
    %if not overwrite and there is sth. in, don't bother

    pf = project.(field);
    if ~ischar(pf) && ~isa(pf,'string')
        pf = "";
    end

    if ~strcmp(pf,C.TODO) && strcmp(C.OVERWRITE,C.NO) && ~strcmp(field, C.FORCE_OVERWRITE)
        en = C.NO_TODO;
        return
    end
    %otherwise actually analyze and enrich
    fprintf("Enriching project %i with %s\n", project.(C.P_NUM), field)
    try
        en_function = en_tuple{2};
        en = en_function(project);
        if ~isa(en,'float')
            en = string(en);
        end
    catch ME
        disp(ME)
        en = C.ERROR;
    end
return

function all_projects = maybe_init(all_projects, new_field)
    global C
    sample_project = all_projects(1);
    project_fields = fields(sample_project);
    if any(strcmp(project_fields, new_field))
        return
    end

    for j = 1:length(all_projects)
        all_projects(j).(new_field) = C.TODO;
    end
return











