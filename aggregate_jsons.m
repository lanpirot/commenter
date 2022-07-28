cat commenter
    function aggregate_jsons()
    jsons = find_jsons();
    projects = struct.empty;
    
    C = Helper_functions.create_constants(1, 1);
    
    for i = 1:length(jsons)
        next_projects = jsondecode(fileread(jsons(i).name));
        for j = 1:length(next_projects)
            projects = [projects next_projects(j)];
        end
    end
    
    C = Helper_functions.create_constants(1, length(projects));
    
    
    Helper_functions.saveit(projects, C.all_models_json)
    Helper_functions.make_pretty(C.all_models_json);    
end

function file_list=find_jsons()
    file_list = dir('*.json');
end