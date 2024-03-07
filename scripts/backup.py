import re
import requests
import yaml
import zipfile
import sys
from string import Template
from SPARQLWrapper import SPARQLWrapper, JSON, TURTLE
from urllib.parse import quote
from os.path import join
from os import remove
from tqdm import tqdm

try:
    configFile = sys.argv[1]
except:
    raise ValueError("No config file specified")

def sparqlResultToDict(results):
    rows = []
    for result in results["results"]["bindings"]:
        row = {}
        for key in list(result.keys()):
            row[key] = result[key]["value"]
        rows.append(row)
    return rows

try:
    with open(configFile, 'r') as f:
        config = yaml.safe_load(f)
except:
    raise ValueError("Could not read config file")

sparql = SPARQLWrapper(config['endpoint'])
sparql.setReturnFormat(JSON)

try:
    sparql.setQuery(config['graphsQuery'])
except:
    raise ValueError("Could not construct Graphs Query. Is it set correctly in config?")

try:
    results = sparql.query().convert()
except:
    raise ValueError("Could not fetch graphs from SPARQL endpoint")

additionalGraphs = config['additionalGraphs'] if 'additionalGraphs' in config else []
graphs = [d['g'] for d in sparqlResultToDict(results)] + additionalGraphs

constructTemplate = Template("""
CONSTRUCT {
    ?s ?p ?o .
} WHERE {
  GRAPH <$graph> {
      ?s ?p ?o
  }
}
""")
headers = {
    "Accept": "text/plain"
}

queryTemplate = Template("""CONSTRUCT {
        ?s ?p ?o
        } FROM <$graph> WHERE {
            ?s ?p ?o .
        }""")

print("Exporting graphs")

outputFileTTL = join(config['output'], 'dump.ttl')
outputFileNQ = join(config['output'], 'dump.nq')

# Empty output files
open(outputFileTTL, 'w').close()
open(outputFileNQ, 'w').close()

for graph in tqdm(graphs):
    data = {
        "query": queryTemplate.substitute(graph=graph)
    }
    try:
        response = requests.get(config['endpoint'], headers=headers, params=data)
    except:
        print("Could not fetch data for", graph)
    if response:
        outputTTL = response.content.decode()
        with open(outputFileTTL, 'a') as f:
            f.write(outputTTL)
        # For the NQ output, we insert the graph name at every line of outputTTL before the . at the end of the line
        outputNQ = re.sub(r'\.$', '<%s> .' % graph, outputTTL, flags=re.MULTILINE)
        with open(outputFileNQ, 'a') as f:
            f.write(outputNQ)

# Zip output files
with zipfile.ZipFile(join(config['output'], 'dump.ttl.zip'), 'w') as zipf:
    zipf.write(outputFileTTL, 'dump.ttl')

with zipfile.ZipFile(join(config['output'], 'dump.nq.zip'), 'w') as zipf:
    zipf.write(outputFileNQ, 'dump.nq')

print("Successfully exported %d graphs" % len(graphs))