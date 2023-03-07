buildCommands_Rivet=(
    "-r PluginsHEPMC3/RivetHerwigTree.so Code/HerwigTree.cc -I/home/sukcius/CustomClasses/ -L/home/sukcius/CustomClasses/ -lCustomLibs"
    "PluginsHEPMC3/RivetJewelGen.so Code/JewelGen.cc"
    "PluginsHEPMC3/RivetJewelGenRap.so Code/JewelGenRap.cc"
    "PluginsHEPMC3/RivetMC_GENERIC_VV.so Code/MC_GENERIC_VV.cc"
    "-r PluginsHEPMC3/RivetMCChargeAsymmetry.so Code/ChargeAsymmetry.cc"
#    "PluginsHEPMC3/RivetMC_JETS_VV.so Code/MC_JETS_VV.cc"
)
RemoveFromLDPath ()  { 
    export LD_LIBRARY_PATH=`echo ${LD_LIBRARY_PATH} | awk -v RS=: -v ORS=: "/${1}/ {next} {print}" | sed 's/:*$//'`
}
RemoveFromPath ()  {
    export PATH=`echo ${PATH} | awk -v RS=: -v ORS=: "/${1}/ {next} {print}" | sed 's/:*$//'`
}
CleanupRivetEnv() {
    RemoveFromPath Rivet
    RemoveFromPath YODA
    RemoveFromLDPath Rivet
    RemoveFromLDPath YODA
    RemoveFromLDPath HepMC
    RemoveFromLDPath FastJet
}
CheckMod() {
    test -z ${hepmcv} && hepmcv=`echo $LD_LIBRARY_PATH | grep -Eo 'HepMC[0-9]' | grep -Eo '[0-9]'`
    test -z ${hepmcv} && echo "Could not find the appropriate HepMC version" && return
    test ! -f .Backups/${1}.hepmc${hepmcv} && cp Code/${1} .Backups/${1}.hepmc${hepmcv} && echo "true" && return
    md5f1=$(md5sum Code/${1} | cut -d' ' -f1) 
    md5f2=$(md5sum .Backups/${1}.hepmc${hepmcv} | cut -d' ' -f1)
    if [ "$md5f1" != "$md5f2" ]
    then
	unset md5f1
	unset md5f2
	cp Code/${1} .Backups/${1}.hepmc${hepmcv}
	echo "true"
	return
    fi
    unset md5f1
    unset md5f2
    return
}
function RebuildSinglePlugin() {
    target=`echo ${1} | grep -Eo '[A-Z,a-z,_,0-9]*\.cc'`
    test ! -f Code/${target} && echo "Could not figure out how to build ${target}, skipping" && return
    test ! -z $(CheckMod ${target}) && rivet-build ${1}
    unset target
}
function RebuildAllPlugins_SingleHEPv() {
    hepmcv=`echo $LD_LIBRARY_PATH | grep -Eo 'HepMC[0-9]' | grep -Eo '[0-9]'`
    for i in ${!buildCommands_Rivet[@]}
    do
	buildTarget=`echo ${buildCommands_Rivet[$i]} | sed "s/PluginsHEPMC3/PluginsHEPMC${hepmcv}/g"`
	RebuildSinglePlugin "$buildTarget"
    done
    unset hepmcv
    unset buildTarget
}
RebuildRivetPlugins() {
#    curdir=`pwd`
#    cd ~/RivetPlugins
    RivetHepMC3
    RebuildAllPlugins_SingleHEPv
    RivetHepMC2
    RebuildAllPlugins_SingleHEPv
#    cd $curdir
#    unset curdir
}
