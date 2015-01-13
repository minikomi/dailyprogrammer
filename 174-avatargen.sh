#!/bin/bash

double() {
  while read -r line
  do
    reverse=$(echo $line | rev)
    echo "$line$reverse"
  done
}


main() {
  local nm=$1
  hash=$(echo $nm | md5 )
  trimmed=${hash:16}
  echo $trimmed  \
    | xxd -r -p  \
    | xxd -b -c 1  \
    | awk '{print $2}' \
    | sed 's/1/░/g; s/0/▓/g;' \
    | double
}

main $1
