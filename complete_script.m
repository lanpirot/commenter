function complete_script(min, max)
    warning('off','all')
    format compact

    pwd

    if  ~exist('min','var') || ~exist('max','var')
        folder_list = find_all_projects(system_constants.all_projects_path);
        min = 1;
        max = length(folder_list);
        fprintf("No parameters given. Using default values for min: %i and max: %i.\n", min, max)
    end
    
    global C
    C = Helper_functions.create_constants(min, max);
    
    %create_json(C)
    %enrich_projects(C)
    %enrich_models(C)
    analyze_json(C)
    fprintf("All done for projects %i-%i\n",min,max);
end

function folder_list=find_all_projects(root_dir)
    folder_list = dir(root_dir);
    folder_list = folder_list(3:end);
end


%matlab -nodisplay -nosplash -nodesktop -r "run('filter_simulink_projects.m');exit;"
%matlab -nodisplay -nosplash -nodesktop -r "run('complete_script(1,3)');exit;"