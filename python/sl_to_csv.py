import json
from pathlib import Path

def accu(m):
    docs = m["blocks_with_documentation"]
    lines = ""
    for d in docs:
        lines += d["Type"] + "," + str(d["Level"]) + "," + str(d["length"]) + "\n"
    return lines

def accu_projects(models, cyclo):
    lines = "Type,Level,Length"
    for m in models:
        if (not cyclo or isinstance(m["cyclomatic_complexity"], int)) and isinstance(m["blocks_with_documentation"], list):
            lines += accu(m)
    return lines

def main_loop(sl_cleaned, sl_accu, sl_accu_cyclo):
    with open(sl_cleaned, "r", encoding="utf-8") as json_file:
        models = json.load(json_file, strict=False)
        lines = accu_projects(models, False)
        lines_cyclo = accu_projects(models, True)
    with open(sl_accu, "w+", encoding="utf-8") as file:
        file.write(lines)
    with open(sl_accu_cyclo, "w+", encoding="utf-8") as file:
        file.write(lines_cyclo)


if __name__ == '__main__':
    with open("constants.json", "r") as constants:
        constants = json.load(constants)

    main_loop(Path(constants["sl_cleanedfile"]), Path(constants["sl_accumulated"]), Path(constants["sl_accumulated_with_cyclo"]))
    print("All done!")