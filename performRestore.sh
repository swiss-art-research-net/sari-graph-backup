source .env
CURRENTDIR=$(pwd)

echo "Note: Restoring will ingest the named graphs from the backup and replace the content of the named graphs currently in the triple store"
read -p "Do you really want to restore from backup? (y/n)" -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]
then
    docker exec ${PROJECT_NAME}_graph_backup python /scripts/restore.py ${CONFIG_FILE}
fi
