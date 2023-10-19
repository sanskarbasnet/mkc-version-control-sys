#!/usr/bin/env bash

source_folder="./user"
backup_folder="./allBackups"


if [ -d "$source_folder" ]; then
    mkdir -p "$backup_folder"

    rsync -av "$source_folder/" "$backup_folder/"

    if [ $? -eq 0 ]; then
        echo "Backup completed successfully."
    else
        echo "Backup failed. Please check the source and destination paths."
    fi
else
    echo "Source folder not found: $source_folder"
fi
