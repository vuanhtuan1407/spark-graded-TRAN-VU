#!/bin/bash

BUCKET=gs://clusterdata-2011-2
LOCAL_DIR=./data/clusterdata-2011-2

mkdir -p $LOCAL_DIR

FOLDERS=(job_events machine_attributes machine_events task_constraints task_events task_usage)

for folder in "${FOLDERS[@]}"; do
    echo "Downloading folder: $folder"
    
    mkdir -p $LOCAL_DIR/$folder

    FILES=$(gsutil ls $BUCKET/$folder/ | grep 'part-.*\.csv\.gz')

    FILE_COUNT=$(echo "$FILES" | wc -l)

    if [ $FILE_COUNT -eq 1 ]; then
        gsutil cp $FILES $LOCAL_DIR/$folder/
    else
        for i in $(seq -w 160 164); do
            MATCH=$(echo "$FILES" | grep "part-${i}-of-")
            if [ ! -z "$MATCH" ]; then
                gsutil cp $MATCH $LOCAL_DIR/$folder/
            fi
        done
    fi
done

ROOT_FILES=(MD5SUM SHA1SUM SHA256SUM README schema.csv)
for f in "${ROOT_FILES[@]}"; do
    gsutil cp $BUCKET/$f $LOCAL_DIR/
done
echo "Download completed."