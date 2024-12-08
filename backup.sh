#!/bin/bash

# Configuration
SOURCE_DIR="$HOME/Documents"
BACKUP_BASE="/Volumes/Data/"  # Adjust this path
BACKUP_DIR="$BACKUP_BASE/$(date +%Y%m%d)"  # Creates YYYYMMDD directory
LATEST_LINK="$BACKUP_BASE/latest"
LOG_FILE="$HOME/backup_$(date +%Y%m%d_%H%M%S).log"

# Create logs directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Folders to backup - add or remove as needed
FOLDERS_TO_BACKUP=(
    "Archiv"
    "Bilder"
    # Add more folders as needed
)

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Start backup process
log_message "Starting incremental backup to $BACKUP_DIR"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "ERROR: Source directory not found: $SOURCE_DIR"
    exit 1
fi

# Check if backup drive is mounted
if [ ! -d "$BACKUP_BASE" ]; then
    log_message "ERROR: Backup drive not mounted"
    exit 1
fi

# Create new backup directory
mkdir -p "$BACKUP_DIR"

# Perform backup for each folder
for folder in "${FOLDERS_TO_BACKUP[@]}"; do
    source_path="$SOURCE_DIR/$folder"
    backup_path="$BACKUP_DIR/$folder"
    
    if [ -d "$source_path" ]; then
        log_message "Backing up $folder"
        
        # If we have a previous backup, use it as a reference
        if [ -L "$LATEST_LINK" ]; then
            rsync -av \
                  --exclude=".DS_Store" \
                  --exclude="*.tmp" \
                  --link-dest="$LATEST_LINK/$folder" \
                  "$source_path/" "$backup_path/" \
                  >> "$LOG_FILE" 2>&1
        else
            # First time backup
            rsync -av \
                  --exclude=".DS_Store" \
                  --exclude="*.tmp" \
                  "$source_path/" "$backup_path/" \
                  >> "$LOG_FILE" 2>&1
        fi
        
        if [ $? -eq 0 ]; then
            log_message "Successfully backed up $folder"
        else
            log_message "ERROR: Failed to backup $folder"
        fi
    else
        log_message "WARNING: Source folder not found: $folder"
    fi
done

# Update the "latest" symlink
rm -f "$LATEST_LINK"
ln -s "$BACKUP_DIR" "$LATEST_LINK"

log_message "Backup process completed"