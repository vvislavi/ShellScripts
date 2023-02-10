function h_GetCustomLibs() {
    test -f libCustomLibs.so && rm libCustomLibs.so
    test -f CustomLibsCint_rdict.pcm && rm CustomLibsCint_rdict.pcm
    cp /home/sukcius/CustomClasses/libCustomLibs.so .
    cp /home/sukcius/CustomClasses/CustomLibsCint_rdict.pcm .
}
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
function f_ProcessTree() {
    root -l -b MakeCorrHist.C+\(\"${1}\"\)
}
function PrepareVacuum() {
    echo ${1} > GlobalConfigs/cfg_nEvents_Vacuum
}
function PrepareMedium() {
    echo ${1} > GlobalConfigs/cfg_nEvents_Medium
    echo ${2} > GlobalConfigs/cfg_MediumPar
}
function GenerateRandomNumbers() {
    if [ -z ${2} ]
    then
	echo "Target file was not specified, will use default ( .rndm_default)"
	trgtrndm=".rndm_default"
    else
	trgtrndm=${2}
    fi
    if [ -f ${trgtrndm} ]
    then
	rm ${trgtrndm}
    fi
    for ((i=0; i<${1}; i++))
    do
	echo ${RANDOM} >> ${trgtrndm}
    done
    unset trgtrndm
}
function f_Rivet_Skeleton() {
    #1: analysis name
    #2: input file
    #3: output file
    rivet --ignore-beams -a ${1} ${2} -o ${3} #--analysis-path-append $RIVET_MY_PLUGINS
}
function f_Rivet_Jewel() {
    f_Rivet_Skeleton JewelGen /disk/PublicMCTrees/JEWEL/pp/FiFo_${1}.hepmc RivetData/Output_${1}.yoda
}
function f_Rivet_MCGenMine() {
    f_Rivet_Skeleton MC_GENERIC_VV /disk/PublicMCTrees/JEWEL/pp/FiFo_${1}.hepmc RivetData/Output_${1}.yoda
}
function f_Rivet_Jewel_Full() {
    rivet --ignore-beams -a JewelGen -a JewelGenRap -a MC_GENERIC -a MC_JETS /disk/PublicMCTrees/JEWEL/pp/FiFo_${1}.hepmc -o RivetData/Output_${1}.yoda
}
function f_GenerateVacuum() {
    if [ ! -f RivetJewelGen.so ]
    then
	echo "It seems that rivet plugin does not exist. I was looking for RivetJewelGen.so. Please make sure the setup is ok and rebuild the pluging"
	return
    fi
    rnpf=${1}
    ConFi="RunConfigs/conf_${rnpf}.dat"
    HepFi="RivetOut/FiFo_${rnpf}.hepmc"
    LogFi="logs/log_${rnpf}.txt"
    if [ -f GlobalConfigs/cfg_nEvents_Vacuum ]
    then
	Nev=`cat GlobalConfigs/cfg_nEvents_Vacuum`
    else
	Nev=10000
    fi
    echo "HEPMCFILE ${HepFi}" > ${ConFi}
    echo "LOGFILE ${LogFi}" >> ${ConFi}
    cat template.dat >> ${ConFi}
    echo >>${ConFi}
    echo "NJOB ${rnpf}" >> ${ConFi}
    echo "NEVENT ${Nev}" >> ${ConFi}
    mkfifo ${HepFi}
    ./jewel-2.3.0-vac ${ConFi} &
    rivet --ignore-beams --pwd -a JewelGen ${HepFi}
}
function f_GenerateHEPMCVacuum() {
    rnpf=${1}
    ConFi="RunConfigs/conf_${rnpf}.dat"
    HepFi="/disk/PublicMCTrees/JEWEL/pp/FiFo_${rnpf}.hepmc"
    LogFi="logs/log_${rnpf}.txt"
    if [ -f GlobalConfigs/cfg_nEvents_Vacuum ]
    then
        Nev=`cat GlobalConfigs/cfg_nEvents_Vacuum`
    else
        Nev=10000
    fi
    echo "HEPMCFILE ${HepFi}" > ${ConFi}
    echo "LOGFILE ${LogFi}" >> ${ConFi}
    cat template.dat >> ${ConFi}
    echo >>${ConFi}
    echo "NJOB ${rnpf}" >> ${ConFi}
    echo "NEVENT ${Nev}" >> ${ConFi}
    ./jewel-2.3.0-vac ${ConFi}
}
function f_GenerateMedium() {
    if [ ! -f RivetJewelGen.so ]
    then
	echo "It seems that rivet plugin does not exist. I was looking for RivetJewelGen.so. Please make sure the setup is ok and rebuild the pluging"
	return
    fi
    rnpf=${1}
    ConFi="RunConfigs/conf_${rnpf}.dat"
    HepFi="RivetOut/FiFo_${rnpf}.hepmc"
    LogFi="logs/log_${rnpf}.txt"
    if [ -f GlobalConfigs/cfg_nEvents_Medium ]
    then
        Nev=`cat GlobalConfigs/cfg_nEvents_Medium`
    else 
	Nev=10000
    fi
    if [ -f GlobalConfigs/cfg_MediumPar ]
    then
	MedPar=`cat GlobalConfigs/cfg_MediumPar`
    else
	MedPar=""
    fi
    echo "HEPMCFILE ${HepFi}" > ${ConFi}
    echo "LOGFILE ${LogFi}" >> ${ConFi}
    cat template.dat >> ${ConFi}
    echo >>${ConFi}
    if [ ! -z ${MedPar} ]
    then
        echo "MEDIUMPARAMS ${MedPar}" >> ${ConFi}
    fi
    echo "NJOB ${rnpf}" >> ${ConFi}
    echo "NEVENT ${Nev}" >> ${ConFi}
    mkfifo ${HepFi}
    ./jewel-2.3.0-simple ${ConFi} &
    rivet --ignore-beams --pwd -a JewelGen ${HepFi}
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
function GenerateVacuum() {
    PrepareVacuum ${1}
    GenerateRandomNumbers ${2} GlobalConfigs/RandomList_Vacuum
    Parallelize f_GenerateVacuum GlobalConfigs/RandomList_Vacuum ${3}
}
function GenerateHEPMCVacuum() {
    PrepareVacuum ${1}
    GenerateRandomNumbers ${2} GlobalConfigs/RandomList_Vacuum
    Parallelize f_GenerateHEPMCVacuum GlobalConfigs/RandomList_Vacuum ${3}
}
function GenerateMedium() {
    #1 - Number of events  
    #2 - Medium file
    #2 - Number of times to run the generator                                                                                                                                                                        
    #3 - Number of processes at once                                                                                                                                                                                 
    PrepareMedium ${1} ${2}
    GenerateRandomNumbers ${3} GlobalConfigs/RandomList_Medium
    Parallelize f_GenerateMedium GlobalConfigs/RandomList_Medium ${4}
}
