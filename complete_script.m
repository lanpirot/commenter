function complete_script(min, max)
    warning('off','all')
    format compact

    
    folder_list = find_all_projects(system_constants.all_projects_path1, system_constants.all_projects_path2);
    if  ~exist('min','var') || ~exist('max','var')
        min = 1;
        max = length(folder_list);
        fprintf("No parameters given. Using default values for min: %i and max: %i.\n", min, max)
    else
        folder_list = folder_list(min:max);
    end

    fprintf("Starting computation for %i projects.\n",max-min+1)
    
    global C
    C = Helper_functions.create_constants(min, max);
    C.all_projects = folder_list;
    
    create_json(C)
    enrich_projects(C)
    enrich_models(C)
    %analyze_json(C)
    fprintf("All done for projects %i-%i\n",min,max);
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