function AlienCopy() {
  fiex=`alien_ls $1`
  if [ -z $fiex ]
  then
    return
  fi
  attempts=${3:-10}
  if [ -f $2 ]
  then
    return
  fi
  for cti in 0..$attempts
  do
    if [ -f $2 ]
    then
        return
    fi
    alien_cp $1 $2
  done
}
function copyThings() {
  if [ ! -d copied ]
  then
    mkdir copied
  fi
  for i in `cat $1`
  do
    if [ -f copied/${i}.root ]
    then
      continue
    fi
    aldir=${2}${i}${3}
    mergedFile=`alien_ls $aldir | grep AnalysisResults.root`
    if [ -z $mergedFile ]
    then
      if [ ! -d RBRcopied ]
      then
        mkdir RBRcopied
      fi
      if [ ! -d RBRcopied/${i} ]
      then
        echo "Copying ${i} on job-basis!"
        mkdir RBRcopied/${i}
      fi
      for j in `alien_ls $aldir | grep -Eo '[0-9]*'`
      do
        arexists=`alien_ls $aldir/${j}/AnalysisResults.root | grep AnalysisResults.root`
        if [ -z $arexists ]
        then
          continue
        fi
        if [ ! -f RBRcopied/${i}/${j}.root ]
        then
          AlienCopy alien:${aldir}/${j}/AnalysisResults.root file:RBRcopied/${i}/${j}.root 3
        fi
      done
      echo "Job-by-job copy for $i finished!"
    else
      AlienCopy alien:${aldir}/AnalysisResults.root file:copied/${i}.root 3
    fi
    unset aldir
    unset mergedFile
    unset arexists
  done
}
