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
  "help")
    help
    ;;
  *)
    echo "Oops! Invalid command. Try: -c for command, -r for repository, -f for file."
    ;;
esac
