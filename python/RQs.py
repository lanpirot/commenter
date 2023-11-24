import itertools
import json
import math
import statistics
from pathlib import Path
from collections import defaultdict
from statistics import median
from statistics import mean

import matplotlib
import numpy
from scipy.stats import spearmanr
import pandas as pd
import seaborn as sns # For pairplots and heatmaps
import matplotlib.pyplot as plt

import duplicate_analysis


def zero():
    return 0

def empty_list():
    return []











def report_doc_types(models, cyclo_only):
    if cyclo_only:
        all_cyclo = "cyclo only"
    else:
        all_cyclo = "all"
    next_fig("Table 1, first part, general comment report")
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
    next_fig("Table 4, Simulink comment info for different depths")
    print("$depth$, Model Descriptions, Element Descriptions, Annotations, DocBlocks, $items$, $\\frac{items}{subsystem}$, $\\frac{items}{elements}$, $|items|$, $\\bar{x}_{len}^1$, $M_{len}^1$")

    level_count, subs_per_depth, els_per_depth = defaultdict(zero), defaultdict(zero), defaultdict(zero)
    level_length, docs_per_sub, docs_per_el = defaultdict(empty_list), defaultdict(empty_list), defaultdict(empty_list)
    level_text = defaultdict(empty_list)

    level_type = defaultdict(empty_list)

    for m in models:
        docs = defaultdict(zero)
        for d in m["blocks_with_documentation"]:
            level = d["Level"]
            docs[level] += 1
            level_count[level] += 1
            level_length[level].append(d["length"])
            level_text[level].append(d["doc"])
            if type(level_type[level]) == list:
                level_type[level] = dict()
                for t in ["annotation", "model_description", "docblock", "description"]:
                    level_type[level][t] = 0
            level_type[level][d["Type"]] += 1

        if "subsystem_info" not in m or m["subsystem_info"] == "ERROR":
            continue
        subs = m["subsystem_info"]["SUB_HIST"]
        els = m["subsystem_info"]["NUM_EL_DEPTHS"]
        if isinstance(subs, int):
            subs = [subs]
            els = [els]
        for i, s in enumerate(subs):
            subs_per_depth[i] += subs[i]
            docs_per_sub[i] += [docs[i]/subs[i]]
            els_per_depth[i] += els[i]
            docs_per_el[i] += [docs[i]/subs[i]]

    all_level_counts = sum([level_count[l] for l in level_count])
    all_subs_per_depth = sum([subs_per_depth[l] for l in subs_per_depth])
    all_els_per_depth = sum([els_per_depth[l] for l in els_per_depth])
    all_level_length = sum([sum(level_length[d]) for d in level_length])
    all_texts = list(itertools.chain.from_iterable([level_text[i] for i in range(len(level_count) + 1)]))
    all_dedu_texts = set(all_texts)
    for i in range(len(level_count) + 1):
        if level_count[i]:
            if i == 0:
                add_text = "$^2$"
            elif i == 1:
                add_text = "$^2$"
            else:
                add_text = ""
            if i == 0:
                add_text2 = "$^3$"
            else:
                add_text2 = ""
            #print(f"{i}, {level_count[i]}, {level_count[i]/subs_per_depth[i]:.2f}" + add_text + f", {statistics.stdev(docs_per_sub[i]):.2f}, {level_count[i]/els_per_depth[i]:.3f}" + add_text2 + f", {statistics.stdev(docs_per_el[i]):.2f}, {mean(level_length[i]):.2f}, {median(level_length[i])}, {statistics.stdev((level_length[i])):.2f}")
            print(
                f"{i}, {level_type[i]['model_description']}, {level_type[i]['description']}, {level_type[i]['annotation']}, {level_type[i]['docblock']}, {level_count[i]}, {level_count[i] / subs_per_depth[i]:.2f}" + add_text + f", {level_count[i] / els_per_depth[i]:.3f}" + add_text2 + f", {len(set(level_text[i]))}, {mean([len(i) for i in set(level_text[i])]):.2f}, {median([len(i) for i in set(level_text[i])])}")
    print(
        f"total, {sum([level_type[l]['model_description'] for l in level_type])}, {sum([level_type[l]['description'] for l in level_type])}, {sum([level_type[l]['annotation'] for l in level_type])}, {sum([level_type[l]['docblock'] for l in level_type])}, {all_level_counts},  {all_level_counts / all_subs_per_depth:.2f}, {all_level_counts / all_els_per_depth:.3f}, {len(all_dedu_texts)}, {mean([len(t) for t in all_dedu_texts]):2f}, {median([len(t) for t in all_dedu_texts])}")
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
    gnuplot = matplotlib.cm.get_cmap('gnuplot', 256)
    newcolors = gnuplot(numpy.linspace(0, 1, 256))
    gray = numpy.array([230 / 256, 230 / 256, 230 / 256, 1])
    newcolors[91:167, :] = gray
    newcmp = matplotlib.colors.ListedColormap(newcolors)



    fig = plt.figure()
    fig.set_size_inches(w=4.7747, h=4.7747) #4.7747in == \textwidth
    heatmap = sns.heatmap(df, vmin=-1, vmax=1, annot=True, cmap=newcmp, linewidth=.5, square=True)
    plt.title("Spearman Correlation (metrics are per model)")
    #matplotlib.use("pgf")
    #matplotlib.rcParams.update({
    #    "pgf.texsystem": "pdflatex",
    #    'font.family': 'serif',
    #    'text.usetex': True,
    #    'pgf.rcfonts': False,
    #})

    plt.show()
    #plt.savefig('correlations.pgf')
    return

def report_correlation(models, cc):
    c1c2, c1c2copy = [[]]*len(cc), [[]]*len(cc)
    for i in range(len(c1c2)):
        c1c2[i] = [[]]*len(cc)
    ma = 0
    for i1, c1 in enumerate(cc):
        for i2, c2 in enumerate(cc):
            tudskip = 0
            for m in models:
                if c1 not in m or not m[c1] or type(m[c1]) == str or c2 not in m or not m[c2] or type(m[c2]) == str:
                    continue
                if c1 == 'time_under_development' and m[c1] < 0.0001 or c2 == 'time_under_development' and m[c2] < 0.0001:
                    tudskip += 1
                    continue
                c1c2[i1][i2] = c1c2[i1][i2] + [(m[c1], m[c2])]
                if i1 >= i2:
                    c1c2copy[i1] = c1c2copy[i1] + [m[c1]]
            corr = spearmanr(pd.DataFrame(c1c2[i1][i2]))
            if corr[1] < 0.05:
                ma = max(ma, corr[1])
                c1c2[i1][i2] = corr[0]
            else:
                c1c2[i1][i2] = numpy.nan

    next_fig("Figure 5, the quintile diagram")
    correlating_cc = ['number_of_elements', 'number_of_subsystems', 'cyclomatic_complexity', 'number_of_documentation_items', 'total_doc_chars']
    quintiles = dict()
    for i in range(len(cc)):
        if cc[i] in correlating_cc:
            quintiles[cc[i]] = c1c2copy[i]
    for i in range(len(correlating_cc)):
        l = len(quintiles[correlating_cc[i]])
        q_sorted = sorted(quintiles[correlating_cc[i]])
        quintiles[correlating_cc[i]] = [mean(q_sorted[math.floor(l*(x)/5):math.floor(l*(x+1)/5)]) for x in range(5)]
        print(f"{correlating_cc[i]}: {quintiles[correlating_cc[i]]}")

    next_fig("Figure 4, the heatmap of different model and comment metrics")
    print(f"{tudskip} TUDs were obviously bogus")
    corr_matrix = pd.DataFrame(c1c2, columns=cc, index=cc).round(2)
    print(corr_matrix.to_csv())
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

def report_language_correlation():
    df = pd.read_csv("temp.csv", index_col=0)

    c1c2 = [[]]*len(df)
    for i in range(len(c1c2)):
        c1c2[i] = [[]]*len(c1c2)
    for i in range(len(df)):
        for j in range(len(df)):
            tmp = []
            for l in range(1, df.size // len(df)):
                tmp += [(df.iloc[i][l], df.iloc[j][l])]
            corr = spearmanr(tmp)
            if corr[1] < 0.05:
                c1c2[i][j] = corr[0]
                print(corr[1])
            else:
                c1c2[i][j] = numpy.nan
    corr_matrix = pd.DataFrame(c1c2, columns=df.index, index=df.index).round(2)
    print(corr_matrix.to_csv())
    return





def analyze(models):
    #report_language_correlation()
    report_doc_types(models, False)
    #report_doc_types(models, True)
    report_doc_depths(models)
    models = enrich_models(models)
    #correlation_candidates = ["number_of_elements", "number_of_subsystems", "cyclomatic_complexity", "time_under_development", "number_of_documentation_items", "total_doc_chars", "mean_doc_chars", "median_doc_chars"]
    correlation_candidates = ["number_of_elements", "number_of_subsystems", "cyclomatic_complexity",
                              "time_under_development", "number_of_documentation_items", "total_doc_chars",
                              "mean_doc_chars", "median_doc_chars"]
    report_correlation(models, correlation_candidates)
    return

def main_loop(sl_jsonfile):
    with open(sl_jsonfile, "r", encoding="utf-8") as json_file:
        models = json.load(json_file, strict=False)
        projects = analyze(models)

def next_fig(name):
    print("===========================================================================================================")
    print("Now producing info for, or complete " + name)
    print("===========================================================================================================")

if __name__ == '__main__':
    next_fig("Table 3, the table listing the top 10 most duplicated items for each comment type")
    duplicate_analysis.main2()
    with open("constants.json", "r") as constants:
        constants = json.load(constants)

    main_loop(Path(constants["sl_cleanedfile"]))
    print("All done!")
