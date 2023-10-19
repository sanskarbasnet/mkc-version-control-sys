#!/bin/bash

init() {
echo "initialised"
}
add() {
echo "added"
}
cin(){
echo "Checked in"
}
cout(){
echo "Checked Out"
}
log(){
echo "print log"
}

if [[ $1 =~ ^[0-9]+$ ]]; then
   echo "invalid argument"
   exit 1
elif [ $1 == "init" ]; then
   init
elif [ $1 == "add" ]; then
   add
elif [ $1 == "cin" ]; then
   cin
elif [ $1 ==  "cout" ]; then
   cout
elif [ $1 == "log" ]; then
   log
fi
