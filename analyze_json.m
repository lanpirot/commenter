function analyze_json(C)
    
    all_info = jsondecode(fileread(C.all_models_json));

    annotations = aggregate(all_info,C.ANNOTATIONS);
    docblocks = aggregate(all_info,C.DOCBLOCKS);

    all_info = simple_count(all_info,C.ANNOTATIONS,C.NUM_ANNOTATIONS);
    all_info = simple_count(all_info,C.DOCBLOCKS,C.NUM_DOCBLOCKS);

    
    count_loadable(all_info);
    export(all_info);
    %return
    
    scales = ["linear", "log"];
    fprintf("\tmin\t5\t25\tmed\t75\t90\t95\t99\tmax\tave\tstd.dev.\tnum"+newline)
    for i = 1:2
        global scale
        scale = scales(i);
        
        NUM_SUBSYSTEMS = basic_accumulate(all_info, C.NUM_SUBSYSTEMS);
        NUM_BLOCKS = basic_accumulate(all_info, C.NUM_BLOCKS);        
        NUM_LINES = basic_accumulate(all_info, C.NUM_LINES);
        NUM_DOCBLOCKS = basic_accumulate(all_info, C.NUM_DOCBLOCKS);
        NUM_ANNOTATIONS = basic_accumulate(all_info, C.NUM_ANNOTATIONS);
        disp(" ")
        disp(" ")
    end
end

function en = aggregate(info,prop_string)
    en = ["" ""];
    global C
    projects = info.(C.PROJECTS);
    for i = 1:numel(projects)
        for j = 1:numel(projects(i).(C.MODELS))
            for k = 1:numel(projects(i).(C.MODELS)(j).(prop_string))
                try
                    en(end+1) = projects(i).(C.MODELS)(j).(prop_string)(k).ANNOTATION.Text;
                catch
                end
            end
        end
    end
end

function en = simple_count(info,prop_string,num_prop_string)
    global C
    projects = info.(C.PROJECTS);
    for i = 1:numel(projects)
        for j = 1:numel(projects(i).(C.MODELS))
            info.projects(i).(C.MODELS)(j).(num_prop_string) = numel(projects(i).(C.MODELS)(j).(prop_string));
        end
    end
    en = info;
end

function csv_string = flatten_model(model, project)
    global C
    csv_string = project.(C.DOWNLOAD_URL) + ",";
    properties = [C.M_NUM C.REL_PROJ_PATH C.MODEL_NAME C.NUM_SUBSYSTEMS C.NUM_BLOCKS C.NUM_LINES C.NUM_DOCBLOCKS C.NUM_ANNOTATIONS];
    for i = 1:length(properties)
        csv_string = csv_string + model.(properties(i)) + ",";
    end
    csv_string = extractBetween(csv_string,1,strlength(csv_string)-1) + newline;
end

function export(all_info)
    global C
    projects = all_info.(C.PROJECTS);
    csv_string_models = C.DOWNLOAD_URL + "," + C.M_NUM + "," + C.REL_PROJ_PATH + "," + C.MODEL_NAME + "," + C.NUM_SUBSYSTEMS + "," + C.NUM_BLOCKS + "," + C.NUM_LINES + newline;
    for i = 1:length(projects)
        models = projects(i).(C.MODELS);
        for j = 1:length(models)
            
            
            %%%%%% CSV EXPORTER
            csv_string_models = csv_string_models + flatten_model(models(j), projects(i));
            continue
            %%%%%%
        end
    end
    Helper_functions.saveraw(csv_string_models,"models.csv")
end

function acc_data = basic_accumulate(all_info, keyword)
    global C
    acc_data = [];
    projects = all_info.(C.PROJECTS);
    for i = 1:length(projects)
        models = projects(i).(C.MODELS);
        for j = 1:length(models)
            
            next_data = models(j).(keyword);
            
            if strcmp(next_data, C.ERROR) || strcmp(next_data, C.TODO) || strcmp(next_data, C.NO_TODO)
                continue
            end
            
                       
            if ~isa(next_data, 'double')
                continue
            end
            acc_data = [acc_data next_data];
        end
    end    
    if ~isempty(acc_data)
        present(acc_data, keyword)
    end
end

function cl = count_loadable(all_info)
    global C
    cl = 0;
    ca = 0;
    projects = all_info.(C.PROJECTS);
    for i = 1:length(projects)
        models = projects(i).(C.MODELS);
        for j = 1:length(models)
            next_data = models(j).(C.IS_LOADABLE);
            ca = ca + 1;
            if strcmp(next_data, C.YES)
                cl = cl + 1;
            end
        end
    end
    fprintf("%i of %i models were analyzed.\n", cl, ca)
end

function acc = present(acc_data, keyword)
    global C
    a = sort(acc_data);
%     percentiles = [0.01, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 1];
%     acc = struct;
%     for i = 1:length(percentiles)
%         p = percentiles(i);
%         acc.("p"+string(p)) = a(round(p*length(a)));
%     end 
    %fprintf("%s\tmin:%i\t25:%i\tmed:%i\t75:%i\t90:%i\t95:%i\t99:%i\tmax:%i\tnum:%i",keyword,a(1),round(a(round(0.25*length(a)))),round(median(a)),round(a(round(0.75*length(a)))),round(a(round(0.90*length(a)))),round(a(round(0.95*length(a)))),round(a(round(0.99*length(a)))),round(a(end)),length(a))
    
    fprintf("%s\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%.2f\t%.2f\t%i",keyword,a(1),round(a(round(0.05*length(a)))),round(a(round(0.25*length(a)))),round(median(a)),round(a(round(0.75*length(a)))),round(a(round(0.90*length(a)))),round(a(round(0.95*length(a)))),round(a(round(0.99*length(a)))),round(a(end)),mean(a),std(a),length(a))
    disp(" ")
    boxplot(acc_data,'Notch','on')
    ax = gca;
    global scale
    ax.YAxis.Scale = scale;
    xlabel(replace(keyword,"_"," "))
    ylabel('Occurences')
    saveas(gcf, "figs" + C.dir_separator + keyword + "_" + scale);
end