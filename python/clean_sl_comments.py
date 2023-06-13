import json
from pathlib import Path
import html2text
from striprtf.striprtf import rtf_to_text

def clean_html(text):
    if (text[0] == "<" and (text[-1] == ">" or text.endswith(">\n") or text.endswith(">\r\n"))) or text.startswith("<!DOCTYPE HTML"):
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
        original = ud["content"]
        maybe_rtf = clean_rtf(ud["content"])
        if len(original) > 1.25 * len(maybe_rtf):
            maybe_rtf = maybe_rtf.replace(" " * 100, " ").replace(" " * 10, " ").replace(" " * 10, " ").replace(" " * 5, " ").replace(" " * 2, " ")                  #hacky way of 'mitigatin' weird rtftotext output
            return maybe_rtf
        return ud["content"]
    if ud["format"] == "HTML":
        return clean_html(ud["content"])
    if ud["format"] == "RTF":
        return clean_rtf(ud["content"])
    return ""

def unify(doc_item, documentation_text, type):
    out_item = dict()
    #out_item["Handle"] = doc_item["Handle"]
    #if type == "annotation":
    #    out_item["Name"] = ""
    #else:
    #    out_item["Name"] = doc_item["Name"]
    out_item["Type"] = type
    out_item["Level"] = doc_item["Parent"].replace("//", "/").count("/") + 1    #doc_Item["HierarchyDepth"]
    out_item["doc"] = documentation_text
    out_item["length"] = len(documentation_text)
    return out_item

def clean_doc_item(doc_item):
    doc_item["Name"] = clean_html(doc_item["Name"])
    if doc_item["Type"] == "annotation":
        return unify(doc_item, clean_html(doc_item["Text"]), "annotation")
    if doc_item["MaskType"] == "DocBlock":
        return unify(doc_item, clean_docblock(doc_item), "docblock")
    if doc_item["Description"] != "":
        return unify(doc_item, doc_item["Description"], "description")
    # we decided against including these, as they are often picture-links and not texts
    #if doc_item["MaskDisplay"] == "" and doc_item["MaskDisplayString"] == "":
    #    return None
    return None

def enrich_model_with_doctype_counts(m):
    doc_items = m["blocks_with_documentation"]
    m["number_of_model_descriptions"] = len(list(filter(lambda x: x["Type"] == "model_description", doc_items)))
    m["number_of_annotations"] = len(list(filter(lambda x: x["Type"] == "annotation", doc_items)))
    m["number_of_docblocks"] = len(list(filter(lambda x: x["Type"] == "docblock", doc_items)))
    m["number_of_descriptions"] = len(list(filter(lambda x: x["Type"] == "description", doc_items)))
    m["number_of_documentation_items"] = len(doc_items)
    return m

def maybe_append_description(items, descr):
    if descr:
        items.append({"Handle":0, "Name":"", "Type":"model_description", "Level":0, "doc":descr, "length":len(descr)})
    return items
def clean_model(m):
    doc_items = m["blocks_with_documentation"]
    if m["is_loadable"] != "YES" or doc_items == "ERROR":
        return m
    if isinstance(doc_items, dict):
        doc_items = [doc_items]
    cleaned_items = []
    for d in doc_items:
        next_item = clean_doc_item(d)
        if next_item:
            cleaned_items.append(next_item)
    m["blocks_with_documentation"] = maybe_append_description(cleaned_items, m["model_description"])
    del m["model_description"]
    del m["model_name"]
    del m["absolute_path"]
    del m["rel_project_path"]
    del m["is_loadable"]
    m["number_of_elements"] = m["number_of_signal_lines"] + m["number_of_blocks"]
    del m["number_of_signal_lines"]
    del m["number_of_blocks"]
    #m = enrich_model_with_doctype_counts(m)
    return m

def clean_projects(projects):
    cleaned_models = []
    models_tried, models_analyzed = 0, 0
    for p in projects:
        models = p["models"]
        if isinstance(models, dict):
            models = [models]
        for m in models:
            models_tried += 1
            if m["is_loadable"] == "YES" and m["blocks_with_documentation"] != "ERROR":
                cleaned_models.append(clean_model(m))
                models_analyzed += 1
    print(f"We tried to analyze {models_tried} models, and succeeded in {models_analyzed} models.")
    return cleaned_models

def main_loop(sl_jsonfile, sl_cleanedfile):
    with open(sl_jsonfile, "r", encoding="utf-8") as json_file:
        projects = json.load(json_file, strict=False)
        projects = clean_projects(projects)
    with open(sl_cleanedfile, "w+", encoding="utf-8") as file:
        json.dump(projects, file, ensure_ascii=False, indent=3)

if __name__ == '__main__':
    with open("constants.json", "r") as constants:
        constants = json.load(constants)

    main_loop(Path(constants["sl_jsonfile"]), Path(constants["sl_cleanedfile"]))
    print("All done!")
