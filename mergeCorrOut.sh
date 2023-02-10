function MergeCorrOutput() {
    if [ -f MergedProcessed/${1}.root ] 
    then
	rm MergedProcessed/${1}.root
    fi
    hadd -f MergedProcessed/${1}.root Processed/*
    rm Processed/*
}
