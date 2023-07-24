import math

import pandas
import json
import matplotlib.pyplot as plt
from pathlib import Path
import html2text
from striprtf.striprtf import rtf_to_text


def count_chars(text):
    if type(text) is str:
        return len(text)
    return 0

def count_lines(text):
    if type(text) is str:
        return text.count("\n") + 1
    return 0

def clean_html(text):
    if type(text) is not str or len(text) == 0:
        return ""
    if text[0] == "<" and (text[-1] == ">" or text.endswith(">\n") or text.endswith(">\r\n")):
        return html2text.html2text(text)
    return text

def clean_rtf(text):
    if type(text) is not str or len(text) == 0:
        return ""
    if text[0] == "{" and text[-1] == "}":
        return rtf_to_text(text)
    return text

def clean(df):
    df['Text'] = df.apply(lambda row: clean_html(row['Text']), axis=1)
    df['Text'] = df.apply(lambda row: clean_rtf(row['Text']), axis=1)
    return df

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

def compute_sample_size(l):
    zz = 1.96**2
    pp = 0.5**2
    ee = 0.05**2
    N = l
    zzppee = (zz*pp)/ee
    return math.ceil(zzppee / (1 + zzppee/N))

def main_loop(files_samplesizes, outprefix):
    df = pandas.DataFrame()
    for csv_file in files_samplesizes:
        print(f"Computing {csv_file}")
        df2 = pandas.read_csv(str(csv_file))
        df = df.append(df2)


    for type in set(df['Type']):
        sub_df = df[(df['Type'] == type)]
        print("Number of " + type + f": {len(sub_df)}")
        sub_df.drop_duplicates(subset="Text")
        print("Unique number of " + type + f": {len(sub_df)}")

    print(f"Number of items: {len(df)}")
    df = df.drop_duplicates(subset="Text")
    print(f"Number of items without duplicates: {len(df)}")
    sample_size = compute_sample_size(len(df))
    get_histograms(df, "", outprefix)
    print(f"Sampling {sample_size} items.")

    df = clean(df)

    df = df.sample(sample_size)
    for type in set(df['Type']):
        sub_df = df[(df['Type'] == type)]
        print("Sample size of " + type + f": {len(sub_df)}")
    df.index.name = "sampled_row_number"
    get_histograms(df, "_sampled", outprefix)

    df = clean(df)
    save_sample = Path(str(outprefix)+"sampled.csv")
    df.to_csv(save_sample, sep=",", mode="w+")
    print(f"{save_sample} done.")

def sample(files):
    with open("constants.json", "r") as constants:
        constants = json.load(constants)
    main_loop(files, Path(constants["m_prefix"]))
    return df


if __name__ == '__main__':
    with open("constants.json", "r") as constants:
        constants = json.load(constants)

    files = [Path(constants["sl_accumulated"])]
    main_loop(files, constants["sl_prefix"])

    print("All done!")
