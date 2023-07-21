classdef system_constants
    properties (Constant = true)
        dir_separator = "\"
        
        all_projects_path1 = "C:\svns\simucomp2\models\SLNET_v1\SLNET\SLNET_GitHub"
        all_projects_path2 = "C:\svns\simucomp2\models\SLNET_v1\SLNET\SLNET_MATLABCentral"
        
        %all_projects_path1 = "/storage/homefs/mb21o473/models/SLNET/SLNET_GitHub"
        %all_projects_path2 = "/storage/homefs/mb21o473/models/SLNET/SLNET_MATLABCentral"

        out_path = "C:\svns\alex projects\commenter\sl_out\"
        all_models_json = system_constants.out_path + "allmodels.json"
    end
end