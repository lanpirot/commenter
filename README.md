README

== To run the Simulink model (.slx, .mdl) documentation analysis:
1. Adapt the constants in `system_constants.m` to your system.
	a) your Windows/Unix dir_seperator
	b) path of SLNET (or other Simulink-projects)
	c) output-path of the scripts (will be reused below)
2. Run the Simulink documentation analysis, e.g. 
   `matlab -nodisplay -nosplash -nodesktop -r "run('complete_script()');exit;"` 
   The output .json-File will be put to your path of 1c).
3. Run `analyze_json.m` to aggregate findings of the Simulink model analysis.
   This step outputs .csv files for each category of Simulink documentation (annotation, docblock, etc.)

== To run the Matlab code (.m) documentation analysis:
1. Adapt the constants in `python/constants.json` to your system
	a) `sl_jsonfile` same as in 1 c) of above
	b) `m_jsonfile` output-path of the .m files analysis as .json
	c) The result of 1 b) will be transformed to .csv files with the paramters `m_class` and `m_no_class`
	d) `github_models_path` and `matlab_models_path` are the paths of your SLNET projects
2. run the .m comment analysis with `python all_comments.py`
3. run the transformation of .json to .csv with `python to_csver.py`

== To sample documentation items and produce figures of the distribution:
1. Run `python distribution_analysis_sample.py`
2. This will give a representative sample of m-file comments and slx/mdl-file comments.
   Also: some distribution charts will be constructed, so that you can see, whether the distribution of e.g. 
   comment lengths was impacted much by sampling.
	