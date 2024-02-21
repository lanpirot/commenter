warning('off','all')

dir_separator = "\";
root_dir = "C:\svns\simucomp2\models\SLNET_v1\";
dir_separator = "/";
%root_dir = "/storage/homefs/mb21o473/models/SLNET/SLNET_GitHub";


models = vertcat(dir(fullfile(root_dir, strcat('**',dir_separator,'*.mdl'))),dir(fullfile(root_dir, strcat('**',dir_separator,'*.slx'))));


res = struct("empty", cell(1,0), "area", cell(1,0), "contained", cell(1,0));
for i=1:100%length(models)
    path = models(i).folder + dir_separator + models(i).name;
    fprintf("Analyzing model %i of %i: %s\n", i, length(models), path)
    next = analyze_model(path);
    if ~isempty(next) && ~isempty([next.empty])
        res = [res next];
    end
end

disp(res)
resTable = struct2table(res);
filename = 'area_analysis.csv';
writetable(resTable, filename);
fprintf('Data written to %s\n', filename);



function res = analyze_model(path)
    %load model
    try
        model_handle = load_system(path);
    catch
        res = [];
        return
    end

    %discover subsystems
    subsystems = find_system(model_handle, 'LookUnderMasks','on', 'FollowLinks','on', 'Variants','AllVariants', 'BlockType','SubSystem');
    l = length(subsystems);
    res = struct("empty", cell(1,0), "area", cell(1,0), "contained", cell(1,0));

    %loop over every subsystem: analyze subsystem
    for i=1:l
        next = analyze_subsystem(subsystems(i));
        if ~isempty(next) && ~isempty([next.empty])
            res = [res next];
        end
    end

    %close model
    close_system(path)
end

function res = analyze_subsystem(subsystem)
    
    
    %discover all annotations+blocks, their position, their sizes at depth1
    annotations = find_system(subsystem, 'FindAll','on', 'LookUnderMasks','on', 'FollowLinks','on', 'Variants','AllVariants', 'SearchDepth',1, 'Type','Annotation');
    annotations = enrich_bounding_boxes(annotations);
    blocks = find_system(subsystem, 'LookUnderMasks','on', 'FollowLinks','on', 'Variants','AllVariants', 'SearchDepth',1, 'Type','Block');
    blocks = enrich_bounding_boxes(blocks);

    res(1:length(annotations)) = struct("empty", [], "area", [], "contained", 0);

    %loop over annotations
    for i = 1:length(annotations)
        %find if annotation is empty (holds text, image, other stuff) and
        %their area size
        res(i).empty = isemptyText(annotations(i).handle);
        res(i).area = (annotations(i).dx - annotations(i).x) * (annotations(i).dy - annotations(i).y);

        %loop over all blocks to check how many blocks are contained
        for j = 1:length(blocks)
            %check if block within bounding box of annotation
            if within_bounding_box(annotations(i), blocks(j))
                res(i).contained = res(i).contained + 1;
            end
        end
    end
end

function enriched = enrich_bounding_boxes(handles)
    enriched(1:length(handles)) = struct('handle', [], 'x', [], 'y', [], 'dx', [], 'dy', []);

    for i = 1:length(handles)
        handle = handles(i);
        bb = get_bounding_box(handle);
        enriched(i).handle = handle;
        enriched(i).x = bb.x;
        enriched(i).y = bb.y;
        enriched(i).dx = bb.dx;
        enriched(i).dy = bb.dy;
    end
end

function bool = isemptyText(annotation)
    bool = isempty(get_param(annotation, "Text"));
end

function bool = within_bounding_box(anno, block)
    bool = block.x > anno.x && block.y > anno.y && block.dx < anno.dx && block.dy < anno.dy;
end

function posi = get_bounding_box(handle)
    blockPosition = get_param(handle, 'Position');
    posi.x = blockPosition(1);
    posi.y = blockPosition(2);
    posi.dx = blockPosition(3);
    posi.dy = blockPosition(4);
end