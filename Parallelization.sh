function Parallelize() {
    if [ -z ${1} ]
    then
	echo "Hey there! It seems that you're misusing the function. You should call it with 3 arguments:"
	echo "1: the command you want to run"
	echo "2: a file with input argument for each command (1 per command)"
	echo "3: how many simulatenous jobs you want to run"
	echo "Note that the _total_ number of jobs ran will be the number of entries/arguments in the file that you've specified"
	return
    fi
    IFS=$'\n' read -d '' -r -a lines < ${2}
    c=0
    totcnt=0
    PIDS=()
    for i in ${lines[@]}
    do
        while [ $c -eq $3 ]
        do
            brLoop=0
            sleep 1 #give a short break, so that the script is not running full time                                                                                                                                  
            for j in "${!PIDS[@]}"
            do
                pid="${PIDS[$j]}"
                ps --pid $pid > /dev/null
                if [ "$?" -eq 0 ]
                then
                    continue
                fi
                (( c-=1 ))
                unset "PIDS[$j]"
                echo "Killing a job with PID ${pid}. Last added job is ${i}" >> log
                brLoop=1
            done
            if [ $brLoop -eq 1 ]
            then
                break
            fi
        done
        ${1} $i &
        pid=$!
        PIDS+=("$pid")
        (( c+=1 ))
        (( totcnt+=1 ))
        echo "Added job no. ${totcnt} on run ${i}"
        echo "Added job ${i} with PID ${pid} (tot count ${totcnt})" >> log
    done
    echo "Waiting for the last batch to finish..."
    for pid in "${PIDS[@]}"
    do
        wait $pid
    done
    echo "All finished now!"
}
