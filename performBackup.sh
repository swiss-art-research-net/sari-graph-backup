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
zip ${OUTPUT_FOLDER}/dump.nq.zip ${OUTPUT_FOLDER}/dump.nq
zip ${OUTPUT_FOLDER}/dump.ttl.zip ${OUTPUT_FOLDER}/dump.ttl

if [[ $USE_GIT == "True" ]]
then
    echo "Commiting to git"
    cd $OUTPUT_FOLDER
    git add -A .
    git commit -m "Updating data"
    git push
    cd $CURRENTDIR
fi

docker cp ${OUTPUT_FOLDER}/dump.nq.zip ${TARGET_MP_CONTAINER}:/runtime-data/assets/
docker cp ${OUTPUT_FOLDER}/dump.ttl.zip ${TARGET_MP_CONTAINER}:/runtime-data/assets/