import glob
import os
import json
from bs4 import UnicodeDammit
from pathlib import Path



def gather_projects(path):
    return os.listdir(path)

def gather_models(path):
    os.chdir(path)
    return glob.glob("**/*.m", recursive=True)

def is_a_comment(line):
    return line.lstrip().startswith("%") or line.lstrip().startswith("%{"), line.lstrip().startswith("%{")

def is_inline_comment(line):
    return line.__contains__("%")

def all_behind_percent(line):
    index = line.find("%")
    return line[index:]

def is_empty(line):
    line = line.lstrip()
    return line == ""

def is_classdef(line):
    line = line.lstrip()
    return line.startswith("classdef ") or line.startswith("classdef(")

def get_classdef_lineno(lines):
    for line_no, line in enumerate(lines):
        if is_classdef(line):
            return line_no
    return -1

def is_code(line):
    return not(is_a_comment(line)) and not(is_empty(line)) and not(is_classdef(line))

def is_multi_end(line):
    return line.__contains__("%}")

def gather_comments(model):
    with open(model, 'rb') as file:
        content = file.read()
        suggestion = UnicodeDammit(content)
        encoding = suggestion.original_encoding

    with open(model, mode="r", encoding=encoding) as file:
        try:
            lines = file.readlines()
        except:
            print(model, " has wrong encoding")
            return [], -1
        classdef_lineno = get_classdef_lineno(lines)
        if classdef_lineno >= 0:
            class_comment_possible = True
        else:
            class_comment_possible = False

        comment_list = []
        comment_start = -1
        comment = ""
        is_multi_comment = False
        for line_no, line in enumerate(lines):
            if is_code(line):
                class_comment_possible = False
            is_comment, multi_line = is_a_comment(line)

            if multi_line:
                is_multi_comment = True

            if is_comment or is_multi_comment:
                if comment_start < 0:
                    comment_start = line_no
                is_class_comment = class_comment_possible
                comment += line #strip(line)
                if is_multi_comment:
                    if is_multi_end(line):
                        is_multi_comment = False
                        comment = ""
                        comment_start = -1
                        comment_list += [
                            {"Start_Line": comment_start, "End_Line": line_no - 1, "Comment": comment, "Inline": False,
                             "Class_Comment": is_class_comment}]
            elif comment_start >= 0:
                if is_empty(line):
                    continue
                comment_list += [{"Start_Line": comment_start, "End_Line": line_no - 1, "Comment": comment, "Inline": False, "Class_Comment": is_class_comment}]
                comment = ""
                comment_start = -1
                if is_inline_comment(line):
                    comment_list += [{"Start_Line": line_no, "End_Line": line_no, "Comment": all_behind_percent(line), "Inline": True, "Class_Comment": is_class_comment}]
    return comment_list, classdef_lineno >= 0


def add_to_json(outfile, comment_list):
    with open(outfile,"w+") as file:
        encoded = json.dumps(comment_list, indent=3)
        file.write(encoded)

def main_loop(repo_paths, outfile):
    comment_list = []
    p_num = 0
    m_num_with = 0
    m_num = 0
    for pp in repo_paths:
        projects = gather_projects(pp)
        for e, p in enumerate(projects):
            p_num += 1
            print("Working on ", e, " of ", len(projects), "(", p, ")")
            project_path = Path.joinpath(pp, Path(p))
            models = gather_models(project_path)
            for m in models:
                m_num += 1
                model_path = Path.joinpath(project_path, Path(m))
                cs, classdef = gather_comments(model_path)
                if cs:
                    m_num_with += 1
                    comment_list += [{"Project": project_path, "Model": model_path, "Model Number": m_num, "Classdef found": classdef, "Comments": cs}]
                else:
                    comment_list += [{"Project": project_path, "Model": model_path, "Model Number": m_num, "Classdef found": classdef, "Comments": []}]

    print(f"Analyzed {p_num} projects.")
    print(f"Found comments in {m_num_with} m-files of {m_num} m-files.")
    classdef = sum([1 for model in comment_list if model["Classdef found"]])
    print(f"Found {classdef} classdefs.")
    all_comments = [model["Comments"] for model in comment_list]
    print(f"Found {sum([len(c) for c in all_comments])} comments, altogether.")
    class_comments = sum([len([c for c in comments if c["Class_Comment"] == True]) for comments in all_comments])
    other_comments = sum([len([c for c in comments if c["Class_Comment"] == False]) for comments in all_comments])
    print(f"Of which {class_comments} were Class Comments and {other_comments} other comments.")
    add_to_json(str(outfile), comment_list)

if __name__ == '__main__':
    repo_paths = [Path("C:\\svns\simucomp2\\models\\SLNET_v1\\SLNET_v1\\SLNET_GitHub"),
                  Path("C:\\svns\\simucomp2\\models\\SLNET_v1\\SLNET_v1\\SLNET_MATLABCentral")]
    outfile = Path("C:\\svns\\alex projects\\commenter\\mfiles\\m_comments.json")
    main_loop(repo_paths, outfile)
    print("All done!")
