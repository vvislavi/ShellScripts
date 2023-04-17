function SetJWLDataPathCent() {
    export JWL_Data_Path="/disk/PublicMCTrees/JEWEL/Cent/"
}
function SetJWLDataPathPeri() {
    export JWL_Data_Path="/disk/PublicMCTrees/JEWEL/Peri/"
}
function PrepareMedium() {
    echo ${1} > GlobalConfigs/cfg_nEvents_Medium
    echo ${2} > GlobalConfigs/cfg_MediumPar
}
function f_GetRecoilFlag() {
    recfl=`cat ${1} | grep KEEPRECOILS | grep -Eo "[T,F]"`
    if [ "${recfl}" == "T" ] 
    then
	echo "WithRecoils"
    elif [ "${recfl}" == "F" ]
    then
	echo "NoRecoils"
    else
	echo "DefaultRecoils"
    fi
    unset recfl
}
function f_GenerateMedium() {
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
    SD=${1} f_Rivet_Skeleton ChargeAsymmetry ${HepFi} RivetData/Out_${1}.yoda
}
function f_GenerateHEPMCMedium() {
    rnpf=${1}
    recoilFlag=`f_GetRecoilFlag template.dat`
    echo $recoilFlag
    ConFi="RunConfigs/conf_${rnpf}.dat"
    HepFi="${JWL_Data_Path}/FiFo_${rnpf}_${recoilFlag}.hepmc"
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
    seedFile="GlobalConfigs/RandomList_Medium"
    test -f ${3} && seedFile=${3} || GenerateRandomNumbers ${3} ${seedFile}
    Parallelize f_GenerateMedium ${seedFile} ${4}
    UnsetJewelPath
    unset seedFile
}
function GenerateHEPMCMedium() {
    #1 - Number of events
    #2 - Medium file
    #2 - Number of times to run the generator, or a file with random seeds
    #3 - Number of processes at once
    #First, figure out if doing central or peripheral
    if echo ${2} | grep -q "Central"; then SetJWLDataPathCent ; else SetJWLDataPathPeri ; fi
    PrepareMedium ${1} ${2}
    seedFile="GlobalConfigs/RandomList_Medium"
    test -f ${3} && seedFile=${3} || GenerateRandomNumbers ${3} ${seedFile}
    Parallelize f_GenerateHEPMCMedium ${seedFile} ${4}
    UnsetJewelPath
    unset seetFile
}
