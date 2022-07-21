classdef enrich_projects_container

    methods(Static)

        function en = PROJECT_NAME_DUPLICATES(project)
            if isempty(project.(Constants.MODELS))
                en = {};
                return
            end
            names = {project.(Constants.MODELS).(Constants.MODEL_NAME)};
            [uniques, i, ~] = unique(names,"stable");
            if length(uniques) == length(names)
                en = {};
                return
            end
            dupls = not(ismember(1:numel(names), i));
            dupl_names = names(dupls);
            en = unique(dupl_names);
        end
        
        function en = NUM_MODELS(project)
            en = length(project.(Constants.MODELS));
        end
        
        function len = PROJECT_LENGTH(project)
            Helper_functions.mysystem(project.(Constants.PROJECT_PATH), 'git checkout master');
            commit_list = Helper_functions.mysystem(project.(Constants.PROJECT_PATH), 'git --no-pager log --first-parent master --pretty=format:"%cd"');
            commit_list = splitlines(commit_list);
            
            format = 'eee MMM dd HH:mm:ss yyyy Z';
            end_time = commit_list{1};
            end_time = datetime(end_time,'InputFormat',format,'Timezone','local');
            start_time = commit_list{end};
            start_time = datetime(start_time,'InputFormat',format,'Timezone','local');
            
            len = days(end_time - start_time);
        end
    end
end