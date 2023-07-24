import glob
import os
import json
from bs4 import UnicodeDammit
from pathlib import Path

import distribution_analysis_sample
import m_to_csv


def gather_projects(path):
    return os.listdir(path)

def gather_models(path):
    os.chdir(path)
    return glob.glob("**/*.m", recursive=True)

#first output: is the line a comment?
#second output: is it a multi-line comment?
def is_a_comment(line):
    return line.lstrip().startswith("%") or line.lstrip().startswith("%{"), line.lstrip().startswith("%{")

def get_inline_comment(line):
    if not line.__contains__("%"):
        return None
    line_copy = line[:]
    while len(line) > 0:
        if line.__contains__("%"):
            p_index = line.find("%")
            s_index = line.find("'")
            d_index = line.find('"')
            if 0 <= s_index < p_index:
                ss_index = line[s_index+1:].find("'")
                line = line[s_index + ss_index + 2:]
                continue
            if 0 <= d_index < p_index:
                pp_index = line[p_index + 1:].find('"')
                line = line[p_index + pp_index + 2:]
                continue
            line = line[p_index:]
            return line
        else:
            return None

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
    return not(is_a_comment(line)[0]) and not(is_empty(line)) and not(is_classdef(line))

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
            return [], False
        classdef_lineno = get_classdef_lineno(lines)
        if classdef_lineno >= 0:
            class_comment_possible = True
        else:
            class_comment_possible = False

        comment_list = []
        comment_start = -1
        comment = ""
        is_multi_comment = False
        is_class_comment = False
        for line_no, line in enumerate(lines):
            if is_code(line) and not is_multi_comment:
                class_comment_possible = False
            is_comment, multi_line = is_a_comment(line)

            if multi_line:
                is_multi_comment = True

            if is_comment or is_multi_comment:
                if comment_start < 0:
                    comment_start = line_no
                is_class_comment = class_comment_possible

                if is_multi_comment:
                    comment += line
                else:
                    comment += line.lstrip()
                if is_multi_comment:
                    if is_multi_end(line):
                        is_multi_comment = False
                        comment_list += [{"Start_Line": comment_start, "End_Line": line_no - 1, "Comment": comment, "Inline": False, "Class_Comment": is_class_comment}]
                        comment = ""
                        comment_start = -1
            elif comment_start >= 0:
                if is_empty(line):
                    continue
                comment_list += [{"Start_Line": comment_start, "End_Line": line_no - 1, "Comment": comment, "Inline": False, "Class_Comment": is_class_comment}]
                comment = ""
                comment_start = -1
            if not is_comment:
                in_line_comment = get_inline_comment(line)
                if in_line_comment:
                    comment_list += [{"Start_Line": line_no, "End_Line": line_no, "Comment": in_line_comment, "Inline": True, "Class_Comment": class_comment_possible}]
    return comment_list, classdef_lineno >= 0


def add_to_json(outfile, comment_list):
    with open(outfile, "w+") as file:
        encoded = json.dumps(comment_list, indent=3)
        file.write(encoded)

def main_loop(repo_paths, outfile):
    comment_list = []
    p_num = 0
    m_num_with = 0
    m_num = 0
    pwd = os.getcwd()
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
                    comment_list += [{"Project": str(project_path), "Model": str(model_path), "Model Number": m_num, "Classdef found": classdef, "Comments": cs}]
                else:
                    comment_list += [{"Project": str(project_path), "Model": str(model_path), "Model Number": m_num, "Classdef found": classdef, "Comments": []}]
    os.chdir(pwd)
    print(f"Analyzed {p_num} projects.")
    print(f"Found comments in {m_num_with} m-files of {m_num} m-files.")
    classdef = sum([1 for model in comment_list if model["Classdef found"]])
    print(f"Found {classdef} classdefs.")
    all_comments = [model["Comments"] for model in comment_list]
    print(f"Found {sum([len(c) for c in all_comments])} comments, altogether.")
    class_comments = sum([len([c for c in comments if c["Class_Comment"] == True]) for comments in all_comments])
    other_comments = sum([len([c for c in comments if c["Class_Comment"] == False]) for comments in all_comments])
    print(f"Of which {class_comments} were Class Comments and {other_comments} other comments.")
    add_to_json(outfile, comment_list)

if __name__ == '__main__':
    with open("constants.json", "r") as constants:
        constants = json.load(constants)

    repo_paths = [Path(constants["github_models_path"]),
                  Path(constants["matlab_models_path"])]
    outfile = Path(constants["m_jsonfile"])
    main_loop(repo_paths, outfile)
    m_to_csv.m_to_csv()
    distribution_analysis_sample.sample([Path(constants["m_class"]), Path(constants["m_no_class"])])
    print("All done!")