import pandas
import json
import matplotlib.pyplot as plt
from pathlib import Path
import itertools
from collections import Counter

def get_histograms(df, extra_text, out_file):
    df['char_count'] = df.apply(lambda row: count_chars(row['Text']), axis=1)
    df['line_count'] = df.apply(lambda row: count_lines(row['Text']), axis=1)

    plot_frame = df[["char_count"]]
    mid_text = "char_count" + extra_text
    ax = plot_frame.plot.hist(bins=100, logy=True, title=mid_text)
    plt.savefig(str(out_file) + mid_text + ".png")

    plot_frame = df[["line_count"]]
    mid_text = "line_count" + extra_text
    ax = plot_frame.plot.hist(bins=100, logy=True, title=mid_text)
    plt.savefig(str(out_file) + mid_text + ".png")

def print_line(strlist):
    x = ""
    for s in strlist:
        x += str(s) + ","
    return x[:-1] + "\n"

def main_loop(files_samplesizes, out_folder, constants):
    df = pandas.DataFrame()
    for csv_file in files_samplesizes:
        print(f"Computing {csv_file}")
        df2 = pandas.read_csv(str(csv_file))
        df = df.append(df2.rename(columns={"Class_Comment": "Type"}))

    type_set = constants["type_set"]
    type_set[True] = type_set["True"]
    type_set[False] = type_set["False"]
    del(type_set["True"])
    del(type_set["False"])
    del(type_set["notes"])

    n = 100
    for type in type_set.keys():
        sub_df = df[(df["Type"] == type)]
        print(str(type).upper())
        value_counts = sub_df["Text"].value_counts()
        print(value_counts[:n])
        print("Number of " + str(type) + f": {len(sub_df)}")
        print("Unique number of " + str(type) + f": {len(df[(df['Type'] == type)]['Text'].value_counts())}")
        value_counts.describe()
        print("\n\n")



    with open("fig3.csv", "w+") as csv_file:
        csv_file.write(print_line(["Num"] + list(type_set.values())))
        value_counts = {type: Counter(list(df[(df["Type"] == type)]["Text"].value_counts().values)) for type in type_set.keys()}
        for i in range(10000):
            for type in type_set.keys():
                if value_counts[type][i] == 0:
                    continue
                line = [i]
                for t in type_set.keys():
                    line.append(value_counts[t][i])
                csv_file.write(print_line(line))
                break
    return


def main2():
    with open("constants.json", "r") as constants:
        constants = json.load(constants)

    files = [Path(constants["sl_accumulated"]), Path(constants["m_class"]), Path(constants["m_no_class"])]
    main_loop(files, "figs", constants)

    print("All done!")
