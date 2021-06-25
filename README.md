# SARI Graph Backup

A workflow for exporting custom created data from a triple store for backup purposes

## How to

1. Copy the provided configuration file
    ```bash
    cp config/config.example.yml config.yml
    ```
1. If necessary, adapt the configuration. 
    1. Make sure that the `endpoint` corresponds to your desired SPARQL endpoint and is accessible
    1. Exported Trig files will be stored in the `output` folder
    1. The `graphsQuery` is a SPARQL query that should return a list of named graphs to be exported, bound to the `?g` variable
    1. Any additional named graphs that should be exported can be included as a list of full IRIs under `additionalGraphs`

    ```yaml
    endpoint: http://blazegraph:8080/blazegraph/sparql
    output: './output'

    graphsQuery: '
    PREFIX ldp: <http://www.w3.org/ns/ldp#>
    PREFIX Platform: <http://www.metaphacts.com/ontologies/platform#>
    SELECT DISTINCT ?g WHERE {  
        GRAPH ?g {
            Platform:formContainer ldp:contains ?container .
        }
    }
    '

    additionalGraphs:
    - http://www.metaphacts.com/ontologies/platform#formContainer/context
    ```
1. Run the script by passing the config file as a parameter:
    ```bash
    python scripts/backup.py config/config.yml
    ```

### Using Docker

You can run the scripts in a Docker container, which ensures that the proper Python environment is used. 

1. Copy and amend the provided `.env.example` file
   ```sh
   cp .env.example .env
   ```
1. Set the `PROJECT_NAME` variable to match your project and adapt the other variables as necessary

In this scenario, you need to make sure, that the Docker container has access to the SPARQL endpoint. Amend the provided `docker-compose.network.yml` configuration as required. For example, to connect a backup container to the `bso-data-pipeline` Docker Compose networke, the configuration would look as follow.
```
version: "3"
services:
    backup:
        networks:
            - bso-data-pipeline_default

networks:
    bso-data-pipeline_default:
        external: true
```

Start the configuration with
```sh
docker-compose up -d
```

To run the backup script in the Docker container you can use the Shell script provided:
```sh
bash performBackup.sh
```

### Using Git

You can backup and commit the exported files to a git repository. In order to do so configure a git repository in the output folder. Set the required parameters in the .env file.
```bash
OUTPUT_FOLDER=output
USE_GIT=True
```

To backup and commit to Git, use the shell script provided:
```sh
bash performBackup.sh
```

