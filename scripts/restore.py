import os
import requests
import sys
import yaml
from tqdm import tqdm
from urllib.parse import unquote

try:
    configFile = sys.argv[1]
except:
    raise ValueError("No config file specified")

try:
    with open(configFile, 'r') as f:
        config = yaml.safe_load(f)
except:
    raise ValueError("Could not read config file")

files = []
try:
    for file in os.listdir(os.path.join('..',config['output'])):
        if file.endswith(".trig"):
            files.append({
                "filepath": os.path.join('..', config['output'], file),
                "filename": file
            })
except:
    raise ValueError("Could not read Trig files from backup folder")

for file in files:
    file['graph'] = unquote(file['filename'][:-5])

headers = {'Content-Type': 'application/x-trig',
          'Accept-Charset': 'UTF-8'}

for file in tqdm(files):
    with open(file['filepath'], 'r') as f:
        payload = f.read().encode('utf8')
    requests.delete(config['endpoint'], params={'c': '<' + file['graph'] + '>'})
    requests.post(config['endpoint'], data=payload, headers=headers)