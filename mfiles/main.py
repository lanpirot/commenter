import glob
import os
import json
from bs4 import UnicodeDammit



def gather_projects(path):
    return os.listdir(path)

def gather_models(path):
    os.chdir(path)
    return glob.glob("**/*.m", recursive=True)

def is_a_comment(line):
    return line.lstrip().startswith("%") or line.lstrip().startswith("%{")

def is_inline_comment(line):
    return line.__contains__("%")

def strip(line):
    line = line.lstrip()
    if line.startswith("%"):
        return line[1:]
    elif line.startswith("%{"):
        return line[2:]
    else:
        raise("Non-token comment found at start of comment!")

def all_behind_percent(line):
    index = line.find("%")
    return line[index+1:]

def is_empty(line):
    line = line.lstrip()
    return line == ""

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
            return []
        comment_list = []
        comment_start = -1
        comment = ""
        for line_no, line in enumerate(lines):
            if is_a_comment(line):
                if comment_start < 0:
                    comment_start = line_no
                comment += strip(line)
            elif comment_start >= 0:
                if is_empty(line):
                    continue
                comment_list += [{"Start_Line": comment_start, "End_Line": line_no - 1, "Comment": comment, "Inline": False}]
                comment = ""
                comment_start = -1
                if is_inline_comment(line):
                    comment_list += [{"Start_Line": line_no, "End_Line": line_no, "Comment": all_behind_percent(line), "Inline": True}]
    return comment_list


def add_to_json(outfile, comment_list):
    with open(outfile,"w+") as file:
        encoded = json.dumps(comment_list, indent=3)
        file.write(encoded)

def main_loop(repo_paths, outfile):
    comment_list = []
    for pp in repo_paths:
        projects = gather_projects(pp)
        for e, p in enumerate(projects):
            print("Working on ", e, " of ", len(projects), "(", p, ")")
            project_path = pp + "\\" + p
            models = gather_models(project_path)
            for m in models:
                model_path = project_path + "\\" + m
                c = gather_comments(model_path)
                if c:
                    comment_list += [{"Project": project_path, "Model": model_path, "Comments": c}]
    add_to_json(outfile, comment_list)

if __name__ == '__main__':
    repo_paths = ["C:\\svns\simucomp2\\models\\SLNET_v1\\SLNET_v1\\SLNET_GitHub",
                  "C:\\svns\\simucomp2\\models\\SLNET_v1\\SLNET_v1\\SLNET_MATLABCentral"]
    outfile = "C:\\svns\\alex projects\\commenter\\mfiles\\m_comments.json"
    main_loop(repo_paths, outfile)
    print("All done!")
