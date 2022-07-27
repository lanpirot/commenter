function complete_script(mini, maxi)
    warning('off','all')
    format compact

    
    folder_list = find_all_projects(system_constants.all_projects_path1, system_constants.all_projects_path2);
    if  ~exist('mini','var') || ~exist('maxi','var')
        mini = 1;
        maxi = length(folder_list);
        fprintf("No parameters given. Using default values for min: %i and max: %i.\n", mini, maxi)
    else
        mini = max(mini, 1);
        maxi = min(maxi, length(folder_list));
        folder_list = folder_list(mini:maxi);
    end

    fprintf("Starting computation for %i projects.\n",maxi-mini+1)
    
    global C
    C = Helper_functions.create_constants(mini, maxi);
    C.all_projects = folder_list;
    
    %create_json(C)
    %enrich_projects(C)
    enrich_models(C)
    fprintf("All done for projects %i-%i\n",mini,maxi);
end

%combine all folders (projects) except "." and ".." of two directories 
function folder_list=find_all_projects(root_dir1, root_dir2)
    folder_list1 = dir(root_dir1);
    folder_list1 = folder_list1(3:end);
    folder_list2 = dir(root_dir2);
    folder_list2 = folder_list2(3:end);
    folder_list = [folder_list1 ; folder_list2];
end


%matlab -nodisplay -nosplash -nodesktop -r "run('filter_simulink_projects.m');exit;"
%matlab -nodisplay -nosplash -nodesktop -r "run('complete_script(1,3)');exit;"