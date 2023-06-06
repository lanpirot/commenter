classdef Constants
    
    properties
        MIN = 0
        MAX = 0
        all_models_json = system_constants.out_path + "allmodels.json"
        all_projects = []
    end
    properties(Constant = true)
        
        
        
        ERROR = "ERROR"
        YES = "YES"
        NO = "NO"
        TODO = "NOT_YET_INITTED"
        NO_TODO = "NOTHING_TODO"
        
        NONE = ""
        OVERWRITE = Constants.NO
        FORCE_OVERWRITE = Constants.CYCLOMATIC_COMP
        
        
        
        %global properties
        PROJECTS = "projects"
        HASH_DUPLICATES = "hash_duplicates"
        GLOBAL_NAME_DUPLICATES = "global_name_duplicates"
        MODEL_VARIANTS = "model_variants"
        
        

        %project properties
        P_NUM = "p_num"
        PROJECT_NAME = "project_name"
        PROJECT_PATH = "project_path"
        DOWNLOAD_URL = "download_URL"
        MODELS = "models"
        NUM_MODELS = "number_of_models"
        PROJECT_NAME_DUPLICATES = "project_name_duplicates"
        PROJECT_LENGTH = "project_days_TUD"
        
        old_PROJECT_NAME = "projectName"
        old_DOWNLOAD_URL = "downloadUrl"
        
        
        
        %model properties
        M_NUM = "m_num"
        MODEL_NAME = "model_name"
        IS_LOADABLE = "is_loadable"
        TUD = "time_under_development"
        NUM_LINES = "number_of_signal_lines"
        NUM_BLOCKS = "number_of_blocks"
        SUBSYS_INFO = "subsystem_info"
        CYCLOMATIC_COMP = "cyclomatic_complexity"
        ABSOLUTE_PATH = "absolute_path"
        REL_PROJ_PATH = "rel_project_path"
        FILE_HASH = "checksum"



        %comment properties
        BLOCKS_WITH_DOCU = "blocks_with_documentation"
        M_DESCRIPTION = "model_description"
        B_DESCRIPTION = "block_description"
        ANNOTATION = "annotation"
        DOCBLOCK = "docblock"
        param_list = ["Type","BlockType","Description","Parent","Orientation","ForegroundColor","BackgroundColor","DropShadow","FontAngle","FontName","FontSize","FontWeight","Name","NamePlacement","NameLocation","ShowName","HideAutomaticName","Mask","MaskDisplay","MaskDisplayString","MaskType","versinfo_data","versinfo_string","Selected","Open","Tag","UserData","Commented","Permission","Text"]


        
        
        BUS_OUTPORT_ANALYSIS = "outportbus_info"
        CONTAINED_SIGNALS = "contained_signals"
        SIGNAL_DEPTH = "signal_depth"
        CONTAINED_BUSSES = "contained_busses"
        SUBSYSTEM_LINES = "number_of_lines_in_subsystem"
        SIGNAL_USED_RATIO = "signal_used_ratio"
        INCOMING = "incoming"
        FOLLOWING = "following"
        
        
        COMMIT_HASH = "commit_hash"
        NAME_IN_COMMIT = "name_in_commit"
        
        
        

        
        %all_models_json = "ERROR.json"
        project_description = "project-description.json"
        csv_file = "documentation.csv"
        dir_separator = system_constants.dir_separator
    end
end