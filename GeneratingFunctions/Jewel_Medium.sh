function PrepareMedium() {
    echo ${1} > GlobalConfigs/cfg_nEvents_Medium
    echo ${2} > GlobalConfigs/cfg_MediumPar
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
function f_GenerateHEPMCMedium() {
    rnpf=${1}
    ConFi="RunConfigs/conf_${rnpf}.dat"
    HepFi="/disk/PublicMCTrees/JEWEL/Cent/FiFo_${rnpf}.hepmc"
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
    ./jewel-2.3.0-simple ${ConFi}
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
function GenerateHEPMCMedium() {
    #1 - Number of events
    #2 - Medium file
    #2 - Number of times to run the generator
    #3 - Number of processes at once
    PrepareMedium ${1} ${2}
    GenerateRandomNumbers ${3} GlobalConfigs/RandomList_Medium
    Parallelize f_GenerateHEPMCMedium GlobalConfigs/RandomList_Medium ${4}
}
