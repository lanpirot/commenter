classdef system_constants
    properties (Constant = true)
        dir_separator = "/"
        
        all_projects_path1 = "/home/belix/SLNET/SLNET_GitHub"
        all_projects_path2 = "/home/belix/SLNET/SLNET_MATLABCentral"

        out_path = "/home/belix/commenter/sl_out/"
        all_models_json = system_constants.out_path + "allmodels.json"
    end
end