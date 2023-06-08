import json
from pathlib import Path
import html2text
from striprtf.striprtf import rtf_to_text

def clean_html(text):
    if text[0] == "<" and (text[-1] == ">" or text.endswith(">\n") or text.endswith(">\r\n")):
        return html2text.html2text(text)
    return text

def clean_rtf(text):
    if text[0] == "{" and text[-1] == "}":
        return rtf_to_text(text)
    return text

def clean_docblock(db):
    ud = db["UserData"]
    if isinstance(ud, str):
        return ud
    if "format" not in ud or ud["format"] == "TXT":
        return ud["content"]
    if ud["format"] == "HTML":
        return clean_html(ud["content"])
    if ud["format"] == "RTF":
        return clean_rtf(ud["content"])

    print(ud["format"])
    return ""

def unify(doc_item, documentation_text):
    del doc_item["Text"]
    del doc_item["Description"]
    del doc_item["UserData"]
    doc_item["doc"] = documentation_text
    return doc_item


def clean_doc_item(doc_item):
    if doc_item["Type"] == "annotation":
        return unify(doc_item, doc_item["Text"])
    if doc_item["MaskType"] == "DocBlock":
        return unify(doc_item, clean_docblock(doc_item))
    if doc_item["Description"] != "":
        return unify(doc_item, doc_item["Description"])
    # we decided against including these, as they are often picture-links and not texts
    #if doc_item["MaskDisplay"] == "" and doc_item["MaskDisplayString"] == "":
    #    return None
    return None

def clean_projects(projects):
    cleaned_projects = []
    for p in projects:
        models = p["models"]
        if type(models) == type({}):
            models = [models]
        cleaned_models = []
        for m in models:
            doc_items = m["blocks_with_documentation"]
            if m["is_loadable"] != "YES" or doc_items == "ERROR":
                continue
            if type(doc_items) == type({}):
                doc_items = [doc_items]
            cleaned_items = []
            for d in doc_items:
                next_item = clean_doc_item(d)
                if next_item:
                    cleaned_items.append(next_item)
            m["blocks_with_documentation"] = cleaned_items
            cleaned_models.append(m)
        p["models"] = cleaned_models
        cleaned_projects.append(p)
    return projects

def main_loop(sl_jsonfile, sl_cleanedfile):
    with open(sl_jsonfile, "r", encoding="utf-8") as json_file:
        projects = json.load(json_file, strict=False)
        projects = clean_projects(projects)
        with open(sl_cleanedfile, "w+") as file:
            encoded = json.dumps(projects, indent=3)
            file.write(encoded)

if __name__ == '__main__':
    with open("constants.json", "r") as constants:
        constants = json.load(constants)

    main_loop(Path(constants["sl_jsonfile"]), Path(constants["sl_cleanedfile"]))
    print("All done!")
