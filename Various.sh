function del() {
  if [ -f $1 ]
  then
    rm $1
  else if [ -d $1 ]
    then
      rm  -r $1
    fi
  fi
}
