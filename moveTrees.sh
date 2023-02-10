function MoveJewelTrees() {
    if [ -z ${1} ]
    then
	echo "Please specify title for trees!"
	return
    fi
    if [ ! -d ~/Trees/${1} ]
    then
	mkdir ~/Trees/${1}
    fi
    mv /home/sukcius/JewelPP/ProducedFiles/* ~/Trees/${1}/
    find ~/Trees/${1}/ | grep root > /home/sukcius/JewelPP/Analysis/FileLists/${1}.dat
}
