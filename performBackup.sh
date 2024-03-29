if [[ $ENV_FILE ]]
then
  source $ENV_FILE
else
  source .env
fi

CURRENTDIR=$(pwd)

if [[ $USE_GIT == "True" ]]
then
    cd $OUTPUT_FOLDER
    rm -f *.trig
    cd $CURRENTDIR
fi

docker exec ${PROJECT_NAME}_graph_backup python /scripts/backup.py ${CONFIG_FILE}

if [[ $USE_GIT == "True" ]]
then
    echo "Commiting to git"
    cd $OUTPUT_FOLDER
    git add -A .
    git commit -m "Updating data"
    git push
    cd $CURRENTDIR
fi
