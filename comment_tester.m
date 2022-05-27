open("C:\Users\boll\tmp\DEFLT.slx")
modelName = gcs;
blockHandles = find_system(modelName,'LookUnderMasks', 'on','FindAll','on','FollowLinks','on','type','block');

for i = 1:length(blockHandles)
    block = struct;
    block.handle = blockHandles(i);

    
    block.type = get_param(block.handle,'BlockType');
    parents_names = get_param(block.handle,'Parent');
    block.parent_name = split(parents_names,'/');
    block.parent_name = string(block.parent_name(length(block.parent_name)));
    block.hierarchy_depth = count(parents_names,'/');
    %block.num_inputs = length(get_param(block.handle,'InputSignalNames'));
    %block.num_outputs = length(get_param(block.handle,'OutputSignalNames'));




    %Space
    ullr = get_position(block.handle);
    block.ul = ullr.ul;
    block.lr = ullr.lr;
    %location
    %block.location = get_param(block.handle,'Location');
    block.orientation = get_param(block.handle,'Orientation');

    %Coloring
    block.foregroundColor = get_param(block.handle,'ForegroundColor');
    block.backgroundColor = get_param(block.handle,'BackgroundColor');
    block.shadow = get_param(block.handle,'DropShadow');

    %Text Appearance
    block.fontAngle = get_param(block.handle,'FontAngle');
    block.fontName = get_param(block.handle,'FontName');
    block.fontSize = get_param(block.handle,'FontSize');
    block.fontWeight = get_param(block.handle,'FontWeight');

    %Name
    block.name = string(get_param(block.handle,'Name'));
    block.namePlacement = get_param(block.handle,'NamePlacement');
    block.nameLocation = get_param(block.handle,'NameLocation');
    block.showName = get_param(block.handle,'ShowName');
    block.hideAutomaticName = get_param(block.handle,'HideAutomaticName');

    %Mask
    block.mask = get_param(block.handle,'Mask');
    block.maskDisplay = get_param(block.handle,'MaskDisplay');
    block.maskType = get_param(block.handle,'MaskType'); 
    %...............................

    %Version Information if maskType = VERSION_INFO_BLOCK
    block.versinfo_data = get_param(block.handle,'versinfo_data');
    block.versinfo_string = get_param(block.handle,'versinfo_string');

    %Dynamic
    block.selected = get_param(block.handle,'Selected');
    block.open = get_param(block.handle,'Open');
    

    %Find Other Parameters
    %params = get_param(block.handle,'DialogParameters');
    %params = get_param(block.handle,'IntrinsicDialogParameters');
    %params = get_param(block.handle,'ObjectParameters');

    %maybe useful?
    block.tag = get_param(block.handle,'Tag');
    block.userData = get_param(block.handle,'UserData');
    block.permissions = get_param(block.handle,'Permissions');
    block.commented = get_param(block.handle,'Commented');

    elements_properties{i} = block;
end
close_system(modelName)



%returns position of upper left (ul) and lower right (lr)
%also relative upper left and lower right of first connected block (if any)
function posis = get_position(handle)
    position = get_param(handle,'Position');
    posis = struct;
    posis.ul = [position(1) position(2)];
    posis.lr = [position(3) position(4)];
end
