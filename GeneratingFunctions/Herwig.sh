function h_GenerateHerwigRuns() {
    #1: file with random numbers for seeds
    #2: number of events
    for i in `cat $1`
    do
	echo "set /Herwig/Analysis/HepMCFile:Filename HEPMCOutput/FiFo_${i}.hepmc" > .RunCard_${i}.extra
	echo "set /Herwig/Analysis/HepMCFile:PrintEvent ${2}" >> .RunCard_${i}.extra
    done
    echo ${2} > .NEvents
    test ! -d HEPMCOutput && mkdir HEPMCOutput
}
function f_Herwig() {
    case $1 in
	''|*[!0-9]*) l_runcard=${1} ;;
	*) l_runcard=".RunCard_${1}.extra" ;;
    esac
    rndmnr=`echo ${l_runcard} | grep -Eo '[0-9]*'`
    nevents=10000
    test -f .NEvents && nevents=`cat .NEvents | grep -Eo '[0-9]*'`
    Herwig run LHC-MB.run -x ${l_runcard} -s ${rndmnr} -N $nevents
}
function f_HerwigTrees() {
    test -p HEPMCOutput/FiFo_${1}.hepmc && rm HEPMCOutput/FiFo_${1}.hepmc
    mkfifo HEPMCOutput/FiFo_${1}.hepmc
    f_Herwig ${1} &
    SD=${1} f_Rivet_Skeleton HerwigTree HEPMCOutput/FiFo_${1}.hepmc YodaOut/YodaOut_${1}.yoda
}
function GenerateHerwigTrees() {
    #1: NEvents
    #2: Number of runs
    #3: number of threads
    h_GetCustomLibs
    GenerateRandomNumbers ${2} RandomNumbers_HW
    h_GenerateHerwigRuns RandomNumbers_HW ${1}
    Parallelize f_HerwigTrees RandomNumbers_HW ${3}
}
