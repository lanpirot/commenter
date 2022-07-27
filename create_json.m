function create_json(C)
    warning('off','all')
    format compact

    global C
    hfs = Helper_functions;

    all_projects = C.all_projects;
    
    all_projects_info = struct(C.P_NUM,{},C.PROJECT_PATH,{},C.MODELS,{});

    m = 1;
    for j = 1:min(C.MAX,length(all_projects))
        project_info = gather_project_data(j, all_projects(j).folder, all_projects(j).name);
        project_models = find_all_models(project_info.(C.PROJECT_PATH));
        
        clear all_models_info
        all_models_info = struct(C.M_NUM,{},C.MODEL_NAME,{},C.ABSOLUTE_PATH,{},C.REL_PROJ_PATH,{});
        for i = 1:length(project_models)
            next_model = gather_model_data(m, project_models(i), project_info.(C.PROJECT_PATH));

            m = m+1;
            all_models_info(end+1) = next_model;
        end
        project_info.(C.MODELS) = all_models_info;
        all_projects_info(j) = project_info;
    end

    hfs.saveit(all_projects_info, C.all_models_json)
    hfs.make_pretty(C.all_models_json);
    fprintf("Project creation done.\n\n")
end

function project_info = gather_project_data(p, p_folder, p_name)
    global C
    fprintf("Creating project %i\n", p)
    project_path = p_folder + C.dir_separator + p_name;

    project_info = struct;
    project_info.(C.P_NUM) = p;
    project_info.(C.PROJECT_PATH) = project_path;
end

function model_info = gather_model_data(m, model_file, project_path)
    global C
    model_name = model_file.name;
    model_path = strcat(model_file.folder, C.dir_separator, model_name);

    model_info = struct;
    model_info.(C.M_NUM) = m;
    model_info.(C.MODEL_NAME) = model_name(1:strlength(model_name)-4);
    model_info.(C.ABSOLUTE_PATH) = model_path;
    
    rel_proj_path = replace(extractAfter(model_path, strlength(project_path)+1), "\", "/");
    model_info.(C.REL_PROJ_PATH) = rel_proj_path;
    %model_info.(C.MODEL_COMMITS) = find_commits(project_path, rel_proj_path);
end
        
function cn = find_commits(project_path, rel_path)
    global C  
    cn = struct.empty;
    
    try
        Helper_functions.mysystem(project_path, "git --no-pager checkout -f master");
        commit_list = Helper_functions.mysystem(project_path, sprintf("git --no-pager log --follow --name-only --format='%%h' ""%s""",rel_path));
        commit_list = splitlines(commit_list);


        if length(commit_list) > 3
            for i = 1:3:length(commit_list)
                if length(commit_list{i}) > 8
                    commit_list(i) = extractBetween(commit_list{i},2,length(commit_list{i})-1);
                end
                checksum = get_commit_checksum(project_path, commit_list{i}, commit_list{i+2});
                if isempty(checksum) || (~isempty(cn) && strcmp(checksum, cn(end).(C.FILE_HASH)))
                    continue
                end
                cn(end+1).(C.COMMIT_HASH) = commit_list{i};
                cn(end).(C.NAME_IN_COMMIT) = commit_list{i+2};
                cn(end).(C.FILE_HASH) = checksum;
            end
            if isempty(cn)
                disp(" ")
            end
        end
        Helper_functions.mysystem(project_path, "git --no-pager checkout -f master");
        if isempty(cn)            
            cn(1).(C.COMMIT_HASH) = "master";
            cn(1).(C.NAME_IN_COMMIT) = rel_path;
            cn(1).(C.FILE_HASH) = Simulink.getFileChecksum(project_path + C.dir_separator + rel_path);
        end
        if cn(1).(C.FILE_HASH) ~= Simulink.getFileChecksum(project_path + C.dir_separator + rel_path)
            last_commit.(C.COMMIT_HASH) = "master";
            last_commit.(C.NAME_IN_COMMIT) = rel_path;
            last_commit.(C.FILE_HASH) = Simulink.getFileChecksum(project_path + C.dir_separator + rel_path);
            cn = [last_commit cn];
        else
            cn(1).(C.COMMIT_HASH) = "master";
            cn(1).(C.NAME_IN_COMMIT) = rel_path;
        end
    catch ME
    end
end

function checksum = get_commit_checksum(project_path, commit_id, rel_path)
    global C
    checksum = '';
    try
        Helper_functions.mysystem(project_path, sprintf("git --no-pager checkout -f %s ""%s""", commit_id, rel_path));
        checksum = Simulink.getFileChecksum(project_path + C.dir_separator + rel_path);
        %Helper_functions.mysystem(project_path, sprintf("git --no-pager checkout -f master ""%s""", rel_path));
        Helper_functions.mysystem(project_path, "git --no-pager checkout -f master");
    catch ME
    end
end

function file_list=find_all_models(root_dir)
    global C
    %Helper_functions.mysystem(root_dir, "git --no-pager checkout -f master");
    file_list = vertcat(dir(fullfile(root_dir, strcat('**',C.dir_separator,'*.mdl'))),dir(fullfile(root_dir, strcat('**',C.dir_separator,'*.slx'))));
end
