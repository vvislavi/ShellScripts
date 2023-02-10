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
