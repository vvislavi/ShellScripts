function f_Rivet_Skeleton() {
    #1: analysis name
    #2: input file
    #3: output file
    #You might have to add the --pwd or --analysis-path-append or something to have access to your plugin, if they are not in standard Rivet library
    rivet --ignore-beams -a ${1} ${2} -o ${3} #--analysis-path-append $RIVET_MY_PLUGINS
}
function f_Rivet_Jewel() { #This is the function you want to modify
    f_Rivet_Skeleton YourAnalysisName /path/to/input_${1}.hepmc /path/to/output_${1}.yoda
}
