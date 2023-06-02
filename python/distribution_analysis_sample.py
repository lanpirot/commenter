import pandas
import json
import matplotlib.pyplot as plt
from pathlib import Path
import html2text
from striprtf.striprtf import rtf_to_text


def count_chars(text):
    return len(text)

def count_lines(text):
    return text.count("\n") + 1

def clean_html(text):
    #this is too rudimentary for some cases, e.g. word files start with
    #<html xmlns:v=""urn:schemas-microsoft-com:vml""
    if text[0] == "<" and text[-1] == ">":
        return html2text.html2text(text)
    return text

def clean_rtf(text):
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
    ax = plot_frame.plot.hist(bins=100, logy=True, title=str(out_file)[37:])
    plt.savefig(str(out_file) + "char_count" + extra_text + ".png")

    plot_frame = df[["line_count"]]
    ax = plot_frame.plot.hist(bins=100, logy=True, title=str(out_file)[37:])
    plt.savefig(str(out_file) + "line_count" + extra_text + ".png")

def main_loop(files_samplesizes, sample_size, outprefix):
    df = pandas.DataFrame()
    for f_s in files_samplesizes:
        csv_file = f_s
        print(f"Computing {csv_file}")
        df2 = pandas.read_csv(str(csv_file))
        print(f"Number of items with duplicates: {len(df2)}")
        df2 = df2.drop_duplicates(subset="Text")
        print(f"Number of items without duplicates: {len(df2)}")
        df2['Type'] = str(csv_file)[55:]
        df2['Path'] = df2['Path'].apply(lambda x: x[34:]).apply(lambda x: x.replace("\\","/"))
        df = df.append(df2)



    get_histograms(df, "", outprefix)
    print(f"Sampling {sample_size} items.")
    df = df.sample(sample_size)
    df.index.name = "sampled_row_number"
    get_histograms(df, "_sampled", outprefix)

    df = clean(df)
    df.to_csv(Path(str(outprefix)+"sampled.csv"), sep=",", mode="w+")
    print(f"{outprefix} done.")

if __name__ == '__main__':
    with open("constants.json", "r") as constants:
        constants = json.load(constants)
    files_samplesizes = [Path(constants["m_class"]),
                          Path(constants["m_no_class"])]
    main_loop(files_samplesizes, 383, Path(constants["m_prefix"]))


    files_samplesizes = [Path(constants["annotations"]),
     Path(constants["model_descriptions"]),
     Path(constants["block_descriptions"]),
     Path(constants["doc_blocks"])]
    main_loop(files_samplesizes, 374, constants["sl_prefix"])
    print("All done!")
