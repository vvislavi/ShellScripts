function h_GetCustomLibs() {
    test -f libCustomLibs.so && rm libCustomLibs.so
    test -f CustomLibsCint_rdict.pcm && rm CustomLibsCint_rdict.pcm
    cp /home/sukcius/CustomClasses/libCustomLibs.so .
    cp /home/sukcius/CustomClasses/CustomLibsCint_rdict.pcm .
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
function f_ProcessTree() {
    root -l -b MakeCorrHist.C+\(\"${1}\"\)
}
function f_Rivet_Jewel() {
    f_Rivet_Skeleton JewelGen /disk/PublicMCTrees/JEWEL/pp/FiFo_${1}.hepmc RivetData/Output_${1}.yoda
}
function f_Rivet_ChargeAsym() {
    SD=${1} f_Rivet_Skeleton ChargeAsymmetry /disk/PublicMCTrees/JEWEL/pp/FiFo_${1}.hepmc RivetData/Output_${1}.yoda
}
function f_Rivet_MCGenMine() {
    f_Rivet_Skeleton MC_GENERIC_VV /disk/PublicMCTrees/JEWEL/pp/FiFo_${1}.hepmc RivetData/Output_${1}.yoda
}
function f_Rivet_Jewel_Full() {
    rivet --ignore-beams -a JewelGen -a JewelGenRap -a MC_GENERIC -a MC_JETS /disk/PublicMCTrees/JEWEL/pp/FiFo_${1}.hepmc -o RivetData/Output_${1}.yoda
}
