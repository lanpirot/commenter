import json
from pathlib import Path
import pandas

def print_projects(csv_file, projects, class_only):
    global glob
    rows = []
    for p in projects:
        for c in p["Comments"]:
            if c["Class_Comment"] != class_only:
                continue
            path = p["Model"]
            if '\udca2' in path:
                print("")
            text = c["Comment"]
            start_line = c["Start_Line"]+1 #was counted from line number 0 in the files
            end_line = c["End_Line"]+1
            class_comment = c["Class_Comment"]
            text = text[:-1]
            rows.append([path, text, start_line, end_line, class_comment])

    df = pandas.DataFrame(rows,columns=["Path", "Text", "Start_Line", "End_Line", "Class_Comment"])
    df.to_csv(Path(str(csv_file)), sep=",", mode="w+", index=False, errors='replace')

def main_loop(json_file, csv_file, class_only):
    with open(json_file, "r") as json_file:
        projects = json.load(json_file)
        print_projects(csv_file, projects, class_only)

if __name__ == '__main__':
    json_file = Path("C:\\svns\\alex projects\\commenter\\mfiles\\m_comments.json")
    main_loop(json_file, Path("C:\\svns\\alex projects\\commenter\\mfiles\\m_comments_class.csv"), True)
    main_loop(json_file, Path("C:\\svns\\alex projects\\commenter\\mfiles\\m_comments_no_class.csv"), False)
    print("All done!")