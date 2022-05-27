%open("C:\Users\boll\tmp\DEFLT.slx")
modelName = gcs;
block_handles = find_system(modelName,'LookUnderMasks','on','FindAll','on','FollowLinks','on','type','block');

curr_block = find_current(block_handles);
if curr_block
    disp(all_info_of_block(curr_block))
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
    param_list = ["BlockType","Parent","Orientation","ForegroundColor","BackgroundColor","DropShadow","FontAngle","FontName","FontSize","FontWeight","Name","NamePlacement","NameLocation","ShowName","HideAutomaticName","Mask","MaskDisplay","MaskType","versinfo_data","versinfo_string","Selected","Open","Tag","UserData","Commented","Permission"];

    for p=1:numel(param_list)
        param = param_list(p);
        try
            next_value = get_param(block.Handle,param);
            block.(param) = next_value;
        catch
        end
    end
    
    
    block.HierarchyDepth = count(block.Parent,'/');
    ullr = get_position(block.Handle);
    block.UL = ullr.ul;
    block.LR = ullr.lr;
end

%returns the block handle of model, of the block (if it exists), which is 
%currently selected by the user
function current = find_current(handles)
    for i = 1:length(handles)
        block = handles(i);
        if strcmp(get_param(block,'Selected'),'on')
            current = block;
            return
        end
    end
    current = [];
end


%returns position of upper left (ul) and lower right (lr)
%also relative upper left and lower right of first connected block (if any)
function posis = get_position(handle)
    position = get_param(handle,'Position');
    posis = struct;
    posis.ul = [position(1) position(2)];
    posis.lr = [position(3) position(4)];
end
