source .env

docker exec ${PROJECT_NAME}_graph_backup python /scripts/backup.py ${CONFIG_FILE}

if [[ $USE_GIT == "True" ]]
then
    echo "Commiting to git"
    cd $OUTPUT_FOLDER
    git add .
    git commit -m "Updating data"
    git push
fi