#!/usr/bin/env bash

print_menu () {
 folderPath=$1
 versionSelected=$2  
 ogPath=$3
  echo "Select an operation:"
  echo "[1] Read a Version"
  echo "[2] Rollback a Version"
  echo "[3] Exit"

  read -p "Enter your choice: " choice

  if [ "$choice" == "1" ]; then
    echo "You selected 'Read a Version'."
    cat "${folderPath}/${versionSelected}"
    print_menu folderPath versionSelected
  elif [ "$choice" == "2" ]; then
    echo "$ogPath"
    cat "${folderPath}/${versionSelected}" > "$ogPath"
    echo "Rollback was succesfull"
  elif [ "$choice" == "3" ]; then
    echo "Exiting"
    exit 0 	
  else
    echo "Invalid choice. Please enter 1 or 2."
    print_menu folderPath versionSelected ogPath 
  fi
}

root_function () {
  fileName="hello.txt"
  folderName="./"
  versionsPath="./versions/${fileName}_versions"
  file_path="$folderName$fileName"

  if [ -e "$file_path" ]; then
    echo "File Found, Select an Operation:"
    echo "Versions Available:"
    ls "$versionsPath"
    read -p "Enter complete name of the version: " versionSelected
    if [ -e "$versionsPath/${versionSelected}" ]; then
    	echo "Version Found"
   	print_menu $versionsPath $versionSelected $file_path
    else
    	echo "Version does not exist"
        root_function
     fi
  else
    echo "File does not exist"
  fi
}
root_function

