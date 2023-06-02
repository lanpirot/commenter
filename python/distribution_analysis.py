import pandas
import matplotlib.pyplot as plt
from pathlib import Path
import html2text
from striprtf.striprtf import rtf_to_text


def count_chars(text):
    return len(text)

def count_lines(text):
    return text.count("\n") + 1

def clean_html(text):
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

def main_loop(files_samplesizes):
    for f_s in files_samplesizes:
        csv_file = f_s[0]
        sample_size = f_s[1]
        print(f"Computing {csv_file}")
        df = pandas.read_csv(str(csv_file)+".csv")
        print(f"Number of items with duplicates: {len(df)}")
        df = df.drop_duplicates(subset="Text")
        print(f"Number of items without duplicates: {len(df)}")

        get_histograms(df, "", csv_file)
        print(f"Sampling {sample_size} items.")
        df = df.sample(sample_size)
        df.index.name = "sampled_row_number"
        get_histograms(df, "_sampled", csv_file)

        df = clean(df)
        df.to_csv(Path(str(csv_file)+"_sampled.csv"),sep=",",mode="w+")
        print(f"{csv_file} done.")

if __name__ == '__main__':
    files_samplesizes = [Path("C:\\svns\\alex projects\\commenter\\csvs_unionized_sampled\\m_comments_class"),
    #                      Path("C:\\svns\\alex projects\\commenter\\csvs_unionized_sampled\\m_comments_no_class")]
    # main_loop(files_samplesizes, 383, "C:\\svns\\alex projects\\commenter\\csvs_unionized_sampled\\m_comments_")
    # print("All done!")


    #files_samplesizes = [Path("C:\\svns\\alex projects\\commenter\\csvs_unionized_sampled\\annotations"),
    # Path("C:\\svns\\alex projects\\commenter\\csvs_unionized_sampled\\model_descriptions"),
    # Path("C:\\svns\\alex projects\\commenter\\csvs_unionized_sampled\\block_descriptions"),
    # Path("C:\\svns\\alex projects\\commenter\\csvs_unionized_sampled\\doc_blocks")]
    #main_loop(files_samplesizes, 374, "C:\\svns\\alex projects\\commenter\\csvs_unionized_sampled\\simulink_docu_")
    #print("All done!")
