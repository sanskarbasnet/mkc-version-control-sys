#!/bin/bash

create-rep(){
  local repos="$1"
  for name in $repo; do
    if [ -z "$name" ]; then
        echo "Error: Repository without name??"
        return 1
    fi

    if [ -e "$name" ]; then
      echo "Error: Repository '$name' already exists."
      return 1
    fi

    if mkdir "$name"; then
      mkdir "$name/vcs_utils"
      echo "Repository '$name' created successfully."
      echo "------------------------------------------" >>  "$name/vcs_utils/$name.log"
      echo "Description: Created the repo $name" > "$name/vcs_utils/$name.log"
 echo "Author: $USER" >> "$name/vcs_utils/$name.log"
      echo "Date: $(date)" >> "$name/vcs_utils/$name.log"
      echo "------------------------------------------" >>  "$name/$name.log"
    else
      echo "Error: Unable to create Repository '$name'."
      return 1
    fi
   done
} 

add(){
  local repository="$1"
  local files="$2" 
  if [ -e "$repository" ]; then
    for file in $files; do
      if [ -z "$file" ]; then
        echo "Error: File name cannot be empty."
        return 1
      fi

      if [ -e "$repository/$file" ]; then
        echo "Error: File '$file' already exists."
        return 1
      fi

      if touch "$repository/$file"; then
        chmod u-rw "$repository/$file"
        mkdir -p "./${repository}/vcs_utils/versions"
        mkdir -p "./${repository}/vcs_utils/versions/${files}_version"
        touch "./${repository}/vcs_utils/versions/${files}_version/v1_${files}"
        touch "./${repository}/vcs_utils/versions/${files}_version/version_manager.txt"
        echo "1" > "./${repository}/vcs_utils/versions/version_manager.txt" 
        echo "File '$file' created successfully in repository '$repository'."
        echo "Description: Created file $file in $repository" >> "$repository/vcs_utils/$repository.log"
 echo "Author: $USER" >> "$repository/vcs_utils/$repository.log"
        echo "Date: $(date)" >> "$repository/vcs_utils/$repository.log"
        echo "------------------------------------------" >>  "$repository/vcs_utils/$repository.log"
      else
        echo "Error: Unable to create file '$file'."
        return 1
      fi
    done
  else
      echo "Repository not found"
      return 1
  fi
}

remove(){
  local Myrepository="$1"
  local filename="$2"
 for repository in $Myrepository; do 
 if [ -e "$repository" ];then
    if ! [ -n "$filename" ];then
       if [ -n "$(ls -A "$repository")" ]; then
        read -p "The repository '$repository' is not empty. Are you sure you want to delete it? (y/n): " confirm
        if [ "$confirm" == "y" ]; then
          if rm -r "$repository"; then
            echo "Repository '$repository' removed successfully."
          else
            echo "Error: Unable to remove Repository '$repository'."
            return 1
          fi
        else
          echo "Operation canceled."
        fi
      else
        # Repository is empty, proceed with removal
        if rmdir "$repository"; then
          echo "Repository '$repository' removed successfully."
        else
          echo "Error: Unable to remove Repository '$repository'."
          return 1
        fi
      fi
    else
       for file in $filename; do
       if [ -e "$repository/$file" ]; then
         if rm "$repository/$file" ; then
           echo "File '$file' removed successfully."
         else
           echo "Error: Unable to remove file '$file'."
           return 1
         fi
       else
         echo "Error: File '$file' not found."
         return 1
       fi
     done
    fi
  else
     echo "Repository not found"
  fi
done
}

check-out(){
  local repository="$1"
  local files="$2"
  if [ -e "$repository" ]; then
    for file in $files; do
      if [ -z "$file" ]; then
        echo "Error: File name cannot be empty."
        return 1
      fi

      if [ -e "$repository/$file" ] && [ ! -w "$repository/$file" ] && [ ! -r "$repository/$file" ]; then
         chmod u+rw "$repository/$file"
         echo "$USER" >> "$repository/vcs_utils/editingUser.txt"
        nano "$repository/$file"
        echo "File '$file' in '$repository' has been checked out now."
        echo "Description: Checked out file $file in $repository" >> "$repository/vcs_utils/$repository.log"
        echo "Author: $USER" >> "$repository/vcs_utils/$repository.log"
        echo "Date: $(date)" >> "$repository/vcs_utils/$repository.log"
        echo "------------------------------------------" >>  "$repository/vcs_utils/$repository.log"
     else
       local username=$(cat "$repository/vcs_utils/editingUser.txt")
       echo "This file is currently being edited by $username"
       return 1
      fi
    done
  else
      echo "Repository not found"
      return 1
  fi
}

check-in(){
  local repository="$1"
  local files="$2"
  local message="$3" 
  if [ -e "$repository" ]; then
    for file in $files; do
      if [ -z "$file" ]; then
        echo "Error: File name cannot be empty."
        return 1
      fi

      if [ -w "$repository/$file" ] && [ -r "$repository/$file" ]; then
        chmod u-rw "$repository/$file"
        versionFilePath="./${repository}/vcs_utils/versions/${file}_version/version_manager.txt"
        first_line=$(head -n 1 "$versionFilePath")
        new_number=$((first_line + 1))
        echo "$new_number" > "${versionFilePath}"
        touch "./${repository}/vcs_utils/versions/${file}_version/v${new_number}_file"
        sudo cat "$repository/$file" > "./${repository}/vcs_utils/versions/${file}_version/v${new_number}_file" 
        echo -n "$repository/vcs_utils/editingUser.txt"
        echo "File '$file' in '$repository' has been checked in now."
        echo "Description: Checked in file $file in $repository" >> "$repository/vcs_utils/$repository.log"
 echo "Author: $USER" >> "$repository/vcs_utils/$repository.log"
        echo "Message : $message" >> "$repository/vcs_utils/$repository.log"
        echo "Date: $(date)" >> "$repository/vcs_utils/$repository.log"
 echo "------------------------------------------" >>  "$repository/vcs_utils/$repository.log"
      else
        echo "File already checked in"
      fi
    done
  else
      echo "Repository not found"
      return 1
  fi
}

log(){
  local repository="$1"
 if [ -e "$repository" ]; then
      if [ -e "$repository/vcs_utils/$repository.log" ]; then
        cat "$repository/vcs_utils/$repository.log"
      else
        echo "No Log File Found"
        return 1
      fi
  else
      echo "Repository not found"
      return 1
  fi
}

compile() {
  local repository="$1"
  local files="$2"

  if [ ! -e "$repository" ]; then
    echo "Repository '$repository' does not exist."
    return 1
  fi

  for file in $files; do
    if [ -z "$file" ]; then
      echo "File name can't be empty"
      return 1
    fi

    output="${file%.c}"
    chmod u+rwx "$repository/$file"
    if gcc "$repository/$file" -o "$repository/$output"; then
      echo "Compilation Successful. Executable '$output' created."
      chmod u-rw "$repository/$file"
    else
      echo "Compilation of '$file' failed. Check your code for errors."
    fi
  done
}

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
    sudo cat "$ogPath"
    print_menu $folderPath $versionSelected $ogPath 
  elif [ "$choice" == "2" ]; then
    chmod u+rw "${folderPath}/${versionSelected}"
    chmod u+rw "$ogPath"    
    sudo cat "${folderPath}/${versionSelected}" > "$ogPath"
    chmod u+rw "${ogPath}"
    echo "Rollback was successful"
  elif [ "$choice" == "3" ]; then
    echo "Exiting"
    exit 0 	
  else
    echo "Invalid choice. Please enter 1 or 2."
    print_menu folderPath versionSelected ogPath 
  fi
}

rollback () {
  local fileName="$1"
  local folderName="$2"
  echo "$fileName"
  echo "$folderName"
  versionsPath="./${folderName}/vcs_utils/versions/$1_version"
  file_path="./$folderName/$fileName"
  echo "$file_path"

  if [ -e "$file_path" ]; then
    echo "$file_path"
    echo "File Found, Select an Operation:"
    echo "Versions Available:"
    echo "File Name : $fileName"
    ls "$versionsPath"
    read -p "Enter complete name of the version: " versionSelected
    if [ -e "$versionsPath/${versionSelected}" ]; then
    	echo "Version Found"
   	print_menu $versionsPath $versionSelected $file_path
    else
    	echo "Version does not exist"
        rollback
     fi
  else
    echo "File does not exist"
  fi
}


backup() {
local source_folder="./"
local backup_folder="./allBackups"


if [ -d "$source_folder" ]; then
    mkdir -p "$backup_folder"

    sudo rsync -av "$source_folder/" "$backup_folder/"
    
    if [ $? -eq 0 ]; then
        rm -r "./allBackups/allBackups"
        echo "Backup completed successfully."
    else
        echo "Backup failed. Please check the source and destination paths."
    fi
else
    echo "Source folder not found: $source_folder"
fi

}


help() {
  echo "Usage: $0 -c <command> [-r \"<repository1> <repository2> ...\"] [-f \"<file1> <file2> ...\"]"
  echo
  echo "Options:"

  echo "  -c <command>      Specify the command (create-rep, add, remove, check-out, check-in, log, help)"
  echo "  -r \"<repository> <repository2> ...\"    Specify the repository name(s)"
  echo "  -f \"<file1> <file2> ...\"          Specify the file name(s) (required for add and check-out)"
  echo
  echo "Commands:"
  echo "  create-rep   Create a new repository"
  echo "    Options:"
  echo "      <repository1> <repository2> ...  Specify the repository name(s)"
  echo "    Example:"
  echo "      $0 -c create-rep -r MyProject"
  echo "      $0 -c create-rep -r \"MyProject1 MyProject2 Myproject3\""
  echo "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
  echo
  echo "  add          Add a file to the repository"
  echo "    Options:"
  echo "      <repository>  Specify the repository name"
  echo "      <file1> <file2> ...  Specify the filename(s) to add to the repository"
  echo "    Example:"
  echo "      $0 -c add -r MyProject -f text.txt"
  echo "      $0 -c add -r MyProject1 -f \"text1.txt text2.txt\""
  echo "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
  echo
  echo "  remove       Remove a file or the entire repository"
  echo "    Options:"
  echo "      <repository1> <repository2> ...  Specify the repository name(s)"
  echo "      <file1> <file2> ...  (Optional) Specify the filename(s) to remove from the repository"
  echo "    Example:"
  echo "      $0 -c remove -r MyProject"
  echo "      $0 -c remove -r \"MyProject1 MyProject2\""
  echo "      $0 -c remove -r MyProject -f text.txt"
  echo "      $0 -c remove -r MyProject1 -f \"text1.txt text2.txt\""
  echo "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
  echo
  echo "  check-out    Check out a file for editing"
  echo "    Options:"
  echo "      <repository>  Specify the repository name"
  echo "      <file>        Specify the filename to check out for editing"
  echo "    Example:"
  echo "      $0 -c check-out -r MyProject -f text.txt"
  echo "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
  echo
  echo "  check-in     Check in a file after editing"
  echo "    Options:"
  echo "      <repository>  Specify the repository name"
  echo "    Example:"
  echo "      $0 -c check-in -r MyProject"
  echo "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
  echo
  echo "  log          Display the project log"
  echo "    Options:"
  echo "      <repository>  Specify the repository name"
  echo "    Example:"
  echo "      $0 -c log -r MyProject"
  echo "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
  echo
  echo "  help         Display this help information"
  echo "    Options:"
  echo "      None"
  echo "    Example:"
  echo "      $0 -c help"
  echo "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
}

while getopts ":c:r:f:m:" opt; do
  case $opt in
    c)
      command="$OPTARG"
      ;;
    r)
      repo="$OPTARG"
      ;;
    f)
      file="$OPTARG"
      ;;
    m)
      message="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      echo "Try: -c for command, -r for repository, -f for file(s)."
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

case "$command" in
  "create-rep")
    create-rep "$repo"
    ;;
 "add")
    add "$repo" "$file"
    ;;
  "remove")
    if [ -n "$file" ]; then
      remove "$repo" "$file"
    else
      remove "$repo"
    fi
    ;;
  "check-out")
    if [ -n "$file" ]; then
      check-out "$repo" "$file"
    else
      echo "File name is required for check-out."
      exit 1
    fi
    ;;
  "check-in")
    if [ -n "$file" ]; then
      check-in "$repo" "$file" "$message"
    else
      echo "File name is required for check-in."
      exit 1
    fi
    ;;
  "log")
      if [ -n "$repo" ]; then
       log "$repo"
      else
       echo "Repository name is required to print the log"
       exit 1
      fi
    ;;
 "compile")
      if [ -n "$file" ]; then
       compile "$repo" "$file"
      else
       echo "file name is required to compile"
       exit 1
      fi
    ;;
 "backup")
    backup
    ;;
  "rollback")
    rollback "$file" "$repo"
    ;;
  "help")
    help
    ;;
  *)
    echo "Oops! Invalid command. Try: -c for command, -r for repository, -f for file."
    ;;
esac
