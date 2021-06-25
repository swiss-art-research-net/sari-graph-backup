import re
import requests
import yaml
import sys
from string import Template
from SPARQLWrapper import SPARQLWrapper, JSON, TURTLE
from urllib.parse import quote
from os.path import join
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
    "Accept": "application/x-trig"
}

queryTemplate = Template("""CONSTRUCT {
        ?s ?p ?o
        } FROM <$graph> WHERE {
            ?s ?p ?o .
        }""")

print("Exporting graphs")

for graph in tqdm(graphs):
    data = {
        "query": queryTemplate.substitute(graph=graph)
    }
    try:
        response = requests.get(config['endpoint'], headers=headers, params=data)
    except:
        print("Could not fetch data")
    if response:
        output = response.content.decode()
        # Insert name of named graph
        output = re.sub(r'\n\{', '\n<' + graph + '> {', output, 1)
        filename = quote(graph, safe='') + '.trig'
        with open(join(config['output'], filename), 'w') as f:
            f.write(output)

print("Successfully exported %d graphs" % len(graphs))