# DynamicRoots & shinyRoots Bundled

This repository is out of convenience and combines [DynamicRoots](https://github.com/Topp-Roots-Lab/DynamicRoots) and [shinyRoots](https://github.com/Topp-Roots-Lab/shinyRoots). As such, this repo is a bit messier than them. It is intended to make it easier to run analysis in batches.
## Usage
This document describes how to use the software developed for processing time-series of root reconstructions.

To automatize the whole procedure the python script batch.py calls several separate programs to perform data conversion, root alignment and analysis tasks.

The bin folder containing batch.py, executable programs and the *.dll library files should be located in the folder of the time series. This folder can contain several time-series sets without a folder structure that separates them. The script batch.py will group files within the same time-series set together based on the assumption that the part of the name of the file before the time stamp starting with 't' or 'd' (label used for time or day stamp) is unique for each time-series. The name of the folders where time-series is located and where the results will be written can be changed in the batch.py script.
The script calls the following routines:

For each file in the folder:
* `out2obj.exe fname`

	This converts the input `fname.out` format into `fname.obj` format

For each pair (`fname1`, `fnamex`) of files in a time set:

* `fpcs.exe fname1 fnamex fnamex_a_obj`

	This performs the alignment procedure using Four Point Congruent Set algorithm. It aligns the file `fnamex` to the file `fname1` and outputs the transformed reconstruction into `fnamex_a_obj` file. Here all files are required to be in *.obj format. In addition, the program prints out the transformation matrix used for alignment into `fnamex_a4pcs_ma.txt` file.

* `mesh_align fname1 fnamex_a_obj`

	To improve the alignment even further, this program performs several iterations of the ICP alignment method (Iterative Closest Point). It aligns the file `fnamex_a_obj` to the file `fname1` and outputs the transformation matrix into `fnamex_a_obj.xf` file.
	
* `transform.exe fnamex_a_obj.xf fnamex_a_obj fname_tr`

	This program applies the ICP transformation matrix stored in `fnamex_a_obj.xf` file to the file `fnamex_a_obj` and stores the result in `fname_tr`

For each time-series set:

* `dynamic_roots_64.exe folder_res all_names`

	This program performs analysis of the time-series set. folder_res is the name of the folder where the results of the analysis are written. all_names is the list of the file names of root reconstructions in the time series set. The program uses the files with transformation matrices and assumes the file naming convention described above to access them. The program outputs the following set of files for each time-series set:

* `reconstruction_check.txt`

	for each loaded root reconstruction file it contains the values of volume and surface area (computed as number of voxels and number of exposed faces of voxels). If the surface area is significantly larger than the volume it might be an indicator for an error in the reconstruction procedure. These values are not used anywhere.

* `report.log`

	for each pair of files (`fname1`, `fnamex`) in a set prints out the average and maximum distance between a random subset of points in fname1 and the closest points to them in the aligned reconstruction `fnamex`. If the average distance is large (>10) the file `fnamex` will be skipped when processing time-series set because of potentially bad alignment. `fname1` is the first root reconstruction in the time-series set, `fnamex` is the file with the root reconstruction for the time t>1;

* `switches.log`

	for each pair of files (`fnamex`, `fnamen`) in a set prints out the number of switch events (when a branch length is smaller than the length of a child branch). `fnamen` is the last root reconstruction in the time-series set, fnamex is the file with the root reconstruction for the time t<n;

* `time.log`

	for a time-series set contains information on time (in seconds) spent on analysing the time-series set, computing and printing root traits, total computation time.

* `fnamen_per_branch_dynamics.txt`

	root traits computed per branch (each row) per time stamp (columns);

* `fnamen_seed_stats.txt`

	seed statistics

* `fnamen_geod_depth.iv`

	visual output of the geodesic depth function

* `fnamen_hierarchy.iv`

	visual output of the root hierarchy

* `fnamen_pp.iv`

	visual output of the branch decomposition structure (each branch and seed are visualized with different colors)
	
* `fnamen_pp_no_seed.iv`

	visual output of the branch decomposition structure (each branch is visualized with different colors)
	
* `fnamen_time_function.iv`

	visual output of the time function

* `fnamen_bio_classes.iv`

	visual output of the classification of branches into biological root classes (primary, seminal, crown, and lateral)