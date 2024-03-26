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

rapper -f 'xmlns:crm="http://www.cidoc-crm.org/cidoc-crm"' \
  -f 'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' \
  -f 'xmlns:rico="http://ica.org/standards/RiC/ontology#"' \
  -f 'xmlns:skos="http://www.w3.org/2004/02/skos/core#"' \
  -f 'xmlns:a="http://data.performing-arts.ch/a"' \
  -f 'xmlns:x="http://data.performing-arts.ch/x"' \
  -f 'xmlns:ldp="http://www.w3.org/ns/ldp#"' \
  -f 'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"' \
  -f 'xmlns:prov="http://www.w3.org/ns/prov#"' \
  -f 'xmlns:owl="http://www.w3.org/2002/07/owl#"' \
  -f 'xmlns:frbroo="http://iflastandards.info/ns/fr/frbr/frbroo"' \
  -i turtle -o turtle ${OUTPUT_FOLDER}/dump.ttl > ${OUTPUT_FOLDER}/dump.ttl.prefixed

mv ${OUTPUT_FOLDER}/dump.ttl.prefixed ${OUTPUT_FOLDER}/dump.ttl

rapper -f 'xmlns:crm="http://www.cidoc-crm.org/cidoc-crm"' \
  -f 'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' \
  -f 'xmlns:rico="http://ica.org/standards/RiC/ontology#"' \
  -f 'xmlns:skos="http://www.w3.org/2004/02/skos/core#"' \
  -f 'xmlns:a="http://data.performing-arts.ch/a"' \
  -f 'xmlns:x="http://data.performing-arts.ch/x"' \
  -f 'xmlns:ldp="http://www.w3.org/ns/ldp#"' \
  -f 'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"' \
  -f 'xmlns:prov="http://www.w3.org/ns/prov#"' \
  -f 'xmlns:owl="http://www.w3.org/2002/07/owl#"' \
  -f 'xmlns:frbroo="http://iflastandards.info/ns/fr/frbr/frbroo"' \
  -i nquads -o nquads ${OUTPUT_FOLDER}/dump.nq > ${OUTPUT_FOLDER}/dump.nq.prefixed

mv ${OUTPUT_FOLDER}/dump.nq.prefixed ${OUTPUT_FOLDER}/dump.nq

gzip -c ${OUTPUT_FOLDER}/dump.nq > ${OUTPUT_FOLDER}/dump.nq.gz
gzip -c ${OUTPUT_FOLDER}/dump.ttl > ${OUTPUT_FOLDER}/dump.ttl.gz

if [[ $USE_GIT == "True" ]]
then
    echo "Commiting to git"
    cd $OUTPUT_FOLDER
    git add -A .
    git commit -m "Updating data"
    git push
    cd $CURRENTDIR
fi

docker cp ${OUTPUT_FOLDER}/dump.nq.gz ${TARGET_MP_CONTAINER}:/runtime-data/assets/
docker cp ${OUTPUT_FOLDER}/dump.ttl.gz ${TARGET_MP_CONTAINER}:/runtime-data/assets/