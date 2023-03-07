function PrepareVacuum() {
    echo ${1} > GlobalConfigs/cfg_nEvents_Vacuum
}
function f_GenerateVacuum() {
  #   if [ ! -f RivetJewelGen.so ]
  #   then
	# echo "It seems that rivet plugin does not exist. I was looking for RivetJewelGen.so. Please make sure the setup is ok and rebuild the pluging"
	# return
  #   fi
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
