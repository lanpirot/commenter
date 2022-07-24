classdef Helper_functions
    methods(Static)
        function saveraw(text, save_path)
            fid = fopen(save_path, 'w');
            fprintf(fid, '%s', text);
            fclose(fid);
        end
        
        function saveit(all_projects, save_path)
            json_text = jsonencode(all_projects);
            fid = fopen(save_path, 'w');
            fprintf(fid, '%s', json_text);
            fclose(fid);
        end
        
        function cmdout=mysystem(project_path, cmd)
            project_path = string(project_path);
            cmd = string(cmd);
            %cd to projectPath first, then do stuff
            [status,cmdout] = system('cd ' + project_path + ' && ' + cmd);
            if status ~= 0
                disp(cmd + " raised some kind of Exception, namely " + cmdout + " in " + project_path)
                throw(MException('MYERRORS:CmdError', " raised the exception, above."))
            end
            if ~isempty(cmdout) && cmdout(end) == 10%newline
                cmdout = cmdout(1:end-1);
            end                
        end

        function C = create_constants(min, max)
            globals = who('global');
            clear('global', globals{:});
            C = Constants;
            C.MIN = min;
            C.MAX = max;
            C.all_models_json = "all_models" + string(min) + "-" + string(max) + ".json";
        end
        
        function make_pretty(file_path)
            warning off all
            format compact
            global C

            if ~exist('file_path','var')
                file_path = C.all_models_json;
            end
            allProjects = jsondecode(fileread(file_path));
            json_text = jsonencode(allProjects);
            json_text = prettyjson(json_text);

            fid = fopen(file_path, 'w');
            fprintf(fid, '%s', json_text);
            fclose(fid);
        end
        
        function file_path = make_windows_path(file_path)
            file_path = file_path(34:end);
            file_path = Constants.all_projects_path + file_path;
        end
    end
end