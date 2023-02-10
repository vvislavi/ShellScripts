So... 
Together with this readme file, you'll find two shell scripts, Parallelization.sh and GeneratingFunctions.sh. Both of them have to be sourced (source Parallelization.sh, etc.)
The whole idea is that the function Parallelize (defined in Parallelization.sh) runs N instances of the generating function and then every second or so checks if the process is finished.
Once it's finished, it starts another instance, and so on, until all is finished.
To run it, essentially you call:

Parallelize MyGeneratingFunction InputSubfixFile N

where:
-) MyGeneratingFunction is the command that you need to run. It _always_ takes one (1) argument, that you can use to e.g. specify the input/output file, etc. -- imagination is your friend here
-) InputSubfixFile is a file that contains all the parameters that are passed to the generating function (see previous line). One parameter per call. This means that if you have 50 inputs here, the MyGeneratingFunction will be run 50 times
-) N is how many instances of MyGeneratingFunction you want/are willing to run at a time. That is, if you have 50 inputs (see line above), and N=20, then it will first start 20 instances, and add more whenever one of the previous runs are finished.

In principle, you can use Parallelize on any command you want -- I use it for root analyses, Herwig, Jewel generation, rivet analysis, etc. You can also directly pipe-line the output from Jewel straight to Rivet, if you don't want to store the large HepMC files. But then you'll have to do the generation on-fly every time.

So to adapt this to your own analysis, what you want to do is go to GeneratingFunctions.sh and edit f_Rivet_Jewel as following:
f_Rivet_Skeleton YourAnalysisName /path/to/input_${1}.hepmc /path/to/output_${1}.yoda
Explanation below:
-) f_Rivet_Skeleton calls another function, which essentially just runs rivet with --ignore-beams flag. You might have to add --pwd or --analysis-path-append=SOMETHING to make sure that your plugin is picked up correct
-) /path/to/input_${1}.hepmc is the path to the HepMC file. Remember those parameters defined in InputSubfixFile? That's the ${1} here.
-) /path/to/output_${1}.yoda is the path to output file. You don't want all the outputs to have the same name, hence, the ${1} here, too.

So if you are completely lost, let me give you and example. Assuming you have 2 input files:
/data/MyFile_1.hepmc
/data/MyFile_2.hepmc

you want to run rivet analysis called "Helmgonga"
and you want your output to be stored in:
/output/file_1.yoda
/output/file_2.yoda

you do:
-) Open GeneratingFunctions.sh, edit f_Rivet_Jewel function to:
f_Rivet_Skeleton Helmgonga /data/MyFile_${1}.hepmc /output/file_${1}.yoda

-) Save and close. Then create a new file, call it Subfixes.dat. The contents of this file should be:
1
2

--) **Hackerman tip: "echo 1 > Subfixes.dat && echo 2 >> Subfixes.dat" in terminal

-) source GeneratingFunctions.sh
-) source Parallelization.sh

-) Parallelize f_Rivet_Jewel Subfixes.dat 2
