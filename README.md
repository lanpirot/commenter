= README

This package was tested with MatlabR2023a and Python3.7





== Adapt path and file constants
1. Adapt the constants in `system_constants.m` to your system.
	a) your Windows/Unix dir_seperator
	b) path of SLNET (or other Simulink-projects)
	c) output-path of the scripts (will be reused below). If you change it, you have to manually create this directory!
2. Adapt the constants in `python/constants.json` to your system
	a) `sl_jsonfile` same as in 1 c) of above
	b) `m_jsonfile` output-path of the .m files analysis as .json. If you change it, you have to manually create its directory!
	c) The result of 1 b) will be transformed to .csv files with the paramters `m_class` and `m_no_class`
	d) `github_models_path` and `matlab_models_path` are the paths of your SLNET projects

== To run the Simulink model (.slx, .mdl) documentation analysis:
1. Run the Simulink documentation analysis, e.g.
   `matlab -nodisplay -nosplash -nodesktop -r "run('complete_script()');exit;"` 
   to produce a .json file of all information about Simulink documentation items.
2. Transform this this .json to .csv files with `python sl_to_csv.py`
3. To sample items run `python distribution_analysis_sample.py`, the sampled items will 
   appear in `/samples`. Also: some distribution charts will be constructed, so that you can see, whether the distribution of e.g. 
   comment lengths was impacted much by sampling.

== To run the Matlab code (.m) documentation analysis:
1. Run the .m comment analysis and sampling with `python mine_m_comments.py`, the sampled items will 
   appear in `/samples`. Also: some distribution charts will be constructed, so that you can see, whether the distribution of e.g. 
   comment lengths was impacted much by sampling.

== Produce figures and values of the distribution:
While some basic values, tables and figures of the paper already got produced by the scripts prior, 
most will get produced with `RQs.py`.
	