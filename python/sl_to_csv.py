import json
import csv
from pathlib import Path

import clean_sl_comments


def accu(m):
    docs = m["blocks_with_documentation"]
    lines = ""
    for d in docs:
        lines += d["Type"] + "," + str(d["Level"]) + "," + str(d["length"]) + ',"' + str(d["doc"]).strip() + '"\n'
    return lines

def accu_projects(models, cyclo):
    doc_items = []
    for e, m in enumerate(models):
        if (not cyclo or isinstance(m["cyclomatic_complexity"], int)) and isinstance(m["blocks_with_documentation"], list):
            docs = m["blocks_with_documentation"]
            for d in docs:
                doc_items.append([d["Type"], d["Level"], d["length"], d["doc"].strip()])
    return doc_items

def main_loop(sl_cleaned, sl_accu, sl_accu_cyclo):
    header = ["Type", "Level", "Length", "Text"]
    with open(sl_cleaned, "r", encoding="utf-8") as json_file:
        models = json.load(json_file, strict=False)
        docitems = accu_projects(models, False)
        docitems_cyclo = accu_projects(models, True)


    with open(sl_accu, "w", encoding="utf-8", newline='') as file:
        writer = csv.writer(file)
        writer.writerow(header)
        writer.writerows(docitems)


    with open(sl_accu_cyclo, "w+", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(header)
        writer.writerows(docitems_cyclo)


if __name__ == '__main__':
    clean_sl_comments.clean()
    with open("constants.json", "r") as constants:
        constants = json.load(constants)

    main_loop(Path(constants["sl_cleanedfile"]), Path(constants["sl_accumulated"]), Path(constants["sl_accumulated_with_cyclo"]))
    print("All done!")