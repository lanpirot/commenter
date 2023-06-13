import json
import statistics
from pathlib import Path
from collections import defaultdict
from statistics import median
from statistics import mean

import numpy
from scipy.stats import spearmanr
import pandas as pd
import seaborn as sns # For pairplots and heatmaps
import matplotlib.pyplot as plt


def zero():
    return 0

def empty_list():
    return []











def report_doc_types(models, cyclo_only):
    if cyclo_only:
        all_cyclo = "cyclo only"
    else:
        all_cyclo = "all"
    print(f"Reporting types for {all_cyclo} models")
    all_doc_items = []
    unique_docs = set()
    for m in models:
        if not cyclo_only or isinstance(m["cyclomatic_complexity"], int):
            all_doc_items += m["blocks_with_documentation"]
            for d in m["blocks_with_documentation"]:
                unique_docs.add(d["doc"])

    mdescr_lengths = [d["length"] for d in all_doc_items if d["Type"] == "model_description"]
    annota_lengths = [d["length"] for d in all_doc_items if d["Type"] == "annotation"]
    docblo_lengths = [d["length"] for d in all_doc_items if d["Type"] == "docblock"]
    descri_lengths = [d["length"] for d in all_doc_items if d["Type"] == "description"]
    total = mdescr_lengths + annota_lengths + docblo_lengths + descri_lengths

    #get the counts c
    cmd, ca, cdb, cd, ct = len(mdescr_lengths), len(annota_lengths), len(docblo_lengths), len(descri_lengths), len(total)
    print("Total count: ")
    print(f"model_descriptions {cmd}, annotations {ca}, docblocks {cdb}, descriptions {cd}, total {ct}")
    print(f"{len(unique_docs)} unique documentation items in total (have at least one diverging char)")


    print("Average lengths: ")
    print(f"model_descriptions {mean(mdescr_lengths)}, annotations {mean(annota_lengths)}, docblocks {mean(docblo_lengths)}, descriptions {mean(descri_lengths)}, total {mean(total)}")
    print("Median lengths :")
    print(f"model_descriptions {median(mdescr_lengths)}, annotations {median(annota_lengths)}, docblocks {median(docblo_lengths)}, descriptions {median(descri_lengths)}, total {median(total)}")

    mdescr_levels = [d["Level"] for d in all_doc_items if d["Type"] == "model_description"]
    annota_levels = [d["Level"] for d in all_doc_items if d["Type"] == "annotation"]
    docblo_levels = [d["Level"] for d in all_doc_items if d["Type"] == "docblock"]
    descri_levels = [d["Level"] for d in all_doc_items if d["Type"] == "description"]
    total = mdescr_levels + annota_levels + docblo_levels + descri_levels
    print("Average levels: ")
    print(
        f"model_descriptions {mean(mdescr_levels)}, annotations {mean(annota_levels)}, docblocks {mean(docblo_levels)}, descriptions {mean(descri_levels)}, total {mean(total)}")
    print("Median lengths :")
    print(
        f"model_descriptions {median(mdescr_levels)}, annotations {median(annota_levels)}, docblocks {median(docblo_levels)}, descriptions {median(descri_levels)}, total {median(total)}")
    print()
    return

def report_doc_depths(models):
    print(f"Reporting depths for all models")
    print("Depth, DocItems-per-Subsystem, DocItems-per-Elements, Length(ave), Length(med), std-dev")

    level_count, level_length, subs_per_depth, els_per_depth = defaultdict(zero), defaultdict(empty_list), defaultdict(zero), defaultdict(zero)
    for m in models:
        for d in m["blocks_with_documentation"]:
            level = d["Level"]
            if level == 14:
                print("")
            level_count[level] += 1
            level_length[level].append(d["length"])
        if "subsystem_info" not in m or m["subsystem_info"] == "ERROR":
            continue
        subs = m["subsystem_info"]["SUB_HIST"]
        els = m["subsystem_info"]["NUM_EL_DEPTHS"]
        if isinstance(subs, int):
            subs = [subs]
            els = [els]
        els_per_depth[0] += 1 #!!DELETE AFTER NEXT RUN OF mine_sl_comments.m!!
        for i, s in enumerate(subs):
            if i > 14:
                print("")
            subs_per_depth[i] += subs[i]
            els_per_depth[i+1] += els[i]

    for i in range(len(level_count) + 1):
        if level_count[i]:
            print(f"{i}, {level_count[i]/subs_per_depth[i]:.2f}, {level_count[i]/els_per_depth[i]:.2f}, {mean(level_length[i]):.2f}, {median(level_length[i])}, {statistics.stdev((level_length[i])):.2f}")
    print()
    return

def enrich_models(models):
    for m in models:
        doc_items = m["blocks_with_documentation"]
        m["number_of_model_descriptions"] = len(list(filter(lambda x: x["Type"] == "model_description", doc_items)))
        m["number_of_annotations"] = len(list(filter(lambda x: x["Type"] == "annotation", doc_items)))
        m["number_of_docblocks"] = len(list(filter(lambda x: x["Type"] == "docblock", doc_items)))
        m["number_of_descriptions"] = len(list(filter(lambda x: x["Type"] == "description", doc_items)))
        m["number_of_documentation_items"] = len(doc_items)
        if isinstance(m["subsystem_info"], dict):
            m["number_of_subsystems"] = m["subsystem_info"]["SUB_NUM"]
        m["total_doc_chars"] = sum([d["length"] for d in m["blocks_with_documentation"]])
        if m["number_of_documentation_items"]:
            m["mean_doc_chars"] = mean([d["length"] for d in m["blocks_with_documentation"]])
            m["median_doc_chars"] = median([d["length"] for d in m["blocks_with_documentation"]])
        else:
            m["mean_doc_chars"] = 0
            m["median_doc_chars"] = 0
    return models

def display_correlation(df):
    plt.figure(figsize=(10, 6))
    heatmap = sns.heatmap(df, vmin=-1, vmax=1, annot=True, cmap='gnuplot', linewidth=.5, square=True)
    plt.title("Spearman Correlation")
    plt.show()
    return

def report_correlation(models, cc):
    c1c2 = [[]]*len(cc)
    for i in range(len(c1c2)):
        c1c2[i] = [[]]*len(cc)
    for i1, c1 in enumerate(cc):
        for i2, c2 in enumerate(cc):
            for m in models:
                if c1 not in m or not m[c1] or type(m[c1]) == str or c2 not in m or not m[c2] or type(m[c2]) == str:
                    continue
                c1c2[i1][i2] = c1c2[i1][i2] + [(m[c1], m[c2])]
            corr = spearmanr(pd.DataFrame(c1c2[i1][i2]))
            if corr[1] < 0.01:
                print(c1, c2)
                print(corr[0], corr[1])
                c1c2[i1][i2] = corr[0]
            else:
                c1c2[i1][i2] = numpy.nan
    display_correlation(pd.DataFrame(c1c2, columns=cc, index=cc))
    return

    # for m in models:
    #     skip = False
    #         if c1 not in m or not m[c1] or m[c1] == "ERROR":
    #             skip = True
    #     if cyclo:
    #         #print(m["cyclomatic_complexity"])
    #         if "cyclomatic_complexity" in m and type(m["cyclomatic_complexity"]) == str:
    #             skip = True
    #     if not skip:
    #         list2frame.append(tuple(m[c] for c in cc))
    # display_correlation(pd.DataFrame(list2frame, columns=cc))
    # return


def analyze(models):
    #report_doc_types(models, False)
    #report_doc_types(models, True)
    report_doc_depths(models)
    models = enrich_models(models)
    correlation_candidates = ["number_of_elements", "number_of_subsystems", "number_of_documentation_items", "total_doc_chars", "mean_doc_chars", "median_doc_chars", "time_under_development","cyclomatic_complexity"]
    report_correlation(models, correlation_candidates)
    return

def main_loop(sl_jsonfile):
    with open(sl_jsonfile, "r", encoding="utf-8") as json_file:
        models = json.load(json_file, strict=False)
        projects = analyze(models)

if __name__ == '__main__':
    with open("constants.json", "r") as constants:
        constants = json.load(constants)

    main_loop(Path(constants["sl_cleanedfile"]))
    print("All done!")
