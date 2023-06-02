%open("C:\Users\boll\tmp\DEFLT.slx")
%open('C:\svns\simucomp2\models\SLNET_v1\SLNET_v1\SLNET_GitHub/29702360/LeanPulse-SyD-master/src/matlab/demos/SyDdemo.mdl')
%open("C:\svns\simucomp2\code\commenter\tmp.slx")


open("SLNET/SLNET_GitHub/204030363/simulink_models-master/models/bitcrusher/BC.slx")
modelName = "DEFLT";
modelName = "SyDdemo";
modelName = "BC";
handles = find_system(modelName,'LookUnderMasks','on','RegExp','on','FindAll','on','FollowLinks','on','Type','annotation|block');



curr_block = find_current(handles);
if curr_block
    disp(all_info_of_block(curr_block))
else
    disp("Seems like no block is currently selected, sorry.")
end
%close_system(modelName)


%returns all (deemed useful) information of a given block
%other possible parameters may be in:
%params = get_param(block.Handle,'DialogParameters');
%params = get_param(block.Handle,'IntrinsicDialogParameters');
%params = get_param(block.Handle,'ObjectParameters');
%
%lots of parameters in Masks left untouched
function block = all_info_of_block(handle)
    block = struct;
    block.Handle = handle;
    param_list = ["Type","BlockType","Description","Parent","Orientation","ForegroundColor","BackgroundColor","DropShadow","FontAngle","FontName","FontSize","FontWeight","Name","NamePlacement","NameLocation","ShowName","HideAutomaticName","Mask","MaskDisplay","MaskDisplayString","MaskType","versinfo_data","versinfo_string","Selected","Open","Tag","UserData","Commented","Permission","Text"];

    for p=1:numel(param_list)
        param = param_list(p);
        try
            next_value = get_param(block.Handle,param);
            block.(param) = next_value;
        catch
        end
    end
    
    
    block.HierarchyDepth = count(block.Parent,'/');
    if ~strcmp(block.Parent,'')
        block.HierarchyDepth = block.HierarchyDepth + 1;
    end
    try
        ullr = get_position(block.Handle);
        block.UL = ullr.ul;
        block.LR = ullr.lr;
    catch
    end
end

%returns the deepest block handle of model, of the block (if it exists), which is 
%currently selected by the user
function current = find_current(handles)
    currents = [];
    for i = 1:length(handles)
        element = handles(i);

        try
        if strcmp(get_param(element,'Selected'),'on')
            disp("Selected: " + string(i))
            currents(numel(currents)+1) = element;
            
        end
        catch
            continue
        end
    end
    if currents
        current = currents(1);
    else
        current = [];
        return
    end
    for c = 2:numel(currents)
        if strlength(get_param(current,'Parent')) < strlength(get_param(currents(c),'Parent'))
            current = currents(c);
        end
    end
end

%returns all parameters, that are only found in first block
function unique = find_unique_parameters(block1, block2)
    params1 = [fields(get_param(block1,'DialogParameters'));fields(get_param(block1,'IntrinsicDialogParameters'));fields(get_param(block1,'ObjectParameters'))];
    params2 = [fields(get_param(block2,'DialogParameters'));fields(get_param(block2,'IntrinsicDialogParameters'));fields(get_param(block2,'ObjectParameters'))];
    
    d = 1;
    while d <= numel(params1)
        m = 1;
        while m <= numel(params2)
            if strcmp(params1{d}, params2{m})
                params1(d) = [];
                params2(m) = [];
                d = d - 1;
                break
            end
            m = m+1;
        end
        d = d+1;
    end
    unique = params1;
end


%returns position of upper left (ul) and lower right (lr)
%also relative upper left and lower right of first connected block (if any)
function posis = get_position(handle)
    position = get_param(handle,'Position');
    posis = struct;
    posis.ul = [position(1) position(2)];
    posis.lr = [position(3) position(4)];
end


%Simulink File Meta Data
%In: Property Inspector (or Model Properties)
%Main Parameter: (Model) Description

%Block, Parameter, Bus, Signal
%https://www.mathworks.com/help/simulink/ug/block-properties-dialog-box.html
%Main Parameter: (Element) Description

% %Subsystem, MaskType:CMBlock (ModelInfo block)
% %https://www.mathworks.com/help/simulink/slref/modelinfo.html
% %Main Parameter: MaskDisplayString
% 
% %Subsystem, MaskType: VERSION_INFO_BLOCK
% %
% %Main Parameter: versinfo_string, versinfo_data
% %inner subsystem: MaskDisplay

%DocBlock (external: *.txt/html/rtf, can be used for global comments in generated code)
%https://www.mathworks.com/help/simulink/slref/docblock.html
%Main Parameter: UserData

%Annotation (linkable to blocks/areas, image-annotations)
%https://www.mathworks.com/help/simulink/ug/annotations.html
%Main Parameter: Text/Name





%Note (external: *.mldatx, are associated to model file, read/write mode, updates to currently open system)
%https://www.mathworks.com/help/simulink/ug/annotations.html