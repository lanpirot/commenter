# README

This package was tested with MatlabR2023a and Python3.7
Apart from that, make sure you have the following pip(3) packages installed:
- pandas
- scipy
- bs4
- html2text
- striprtf
- matplotlib
- seaborn
- numpy
- pathlib
- statistics

You will need a Simulink(+Matlab) collection, like (SLNet)[https://zenodo.org/records/5259648].

All matlab scripts (.m) are part of this folder, python scripts are in `./python`.


## Adapt path and file constants
1. Adapt the constants in `system_constants.m` to your system.
	a) your Windows/Unix dir_seperator
	b) path of SLNET (or your Simulink-projects collection, you want to analyze)
	c) output-path of the scripts (will be reused below). If you change it, you have to manually create this directory!
2. Adapt the constants in `python/constants.json` to your system
	a) `sl_jsonfile` same as in 1 c) of above
	b) `m_jsonfile` output-path of the .m files analysis as .json. If you change it, you have to manually create its directory!
	c) The result of 1 b) will be transformed to .csv files with the paramters `m_class` and `m_no_class`
	d) `github_models_path` and `matlab_models_path` are the paths of your SLNET projects, see 1b)

## To run the Simulink model (.slx, .mdl) documentation analysis:
1. Run the Simulink documentation analysis `complete_script`, e.g.
   `matlab -nodisplay -nosplash -nodesktop -r "run('complete_script()');exit;"` 
   to produce a .json file of all information about Simulink documentation items.
   In the default, it is saved at `./sl_out/allmodels.json`.
2. Transform this this .json to .csv files with `python sl_to_csv.py`. This script reports
	how many Simulink models were analyzed and how many succeeded.
3. To sample items run `python distribution_analysis_sample.py`, the sampled items will 
   appear in `./samples`. The last column of Table 1 is shown for Simulink.
   Also: some distribution charts will be constructed, so that you 
   can see, whether the distribution of e.g. comment lengths was impacted much by sampling.

## To run the Matlab code (.m) documentation analysis:
1. Run the .m comment analysis and sampling with `python mine_m_comments.py`, the sampled 
   items will appear in `./samples`. The last column of Table 1 is shown for Matlab.
   Also: some distribution charts will be constructed, so that you can see, whether the distribution of e.g. 
   comment lengths was impacted much by sampling.

## Produce figures and values of the distribution:
While some basic values, tables and figures of the paper already got produced by the scripts prior, 
most will get produced with `RQs.py`.

RQs.py will print the data for Fig. 3 into a file `./python/fig3.csv`, all other data for figures 
or tables is print to the console.

All other data of figures and tables is in `comment_analysis.xlsx`.



## Overall, the tables and figures are reproduced by the following:
Table 1 in RQs.py + mine_m_comments.py + distribution_analysis_sample.py
Fig. 3 with RQs.py
Table 2, 3 in "Most duplicated items" tab of `comment_analysis.xlsx`
Fig. 4 with RQs.py
Table 4 with RQs.py
Fig. 5 with RQs.py
Table 5, Fig. 6 in "Stats" tab of `comment_analysis.xlsx`
Fig. 7 in "Heatmaps" tab of `comment_analysis.xlsx`
Table 6 in "Internal Stats" tab of `comment_analysis.xlsx`