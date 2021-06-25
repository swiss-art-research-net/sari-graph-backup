FROM python:3.8

RUN apt-get -qq update && \
    apt-get -q -y upgrade && \
    apt-get install -y sudo curl wget locales && \
    rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8

RUN apt update
# Install Python packages
RUN pip install urllib3 requests tqdm sparqlwrapper PyYAML

# Install task runner (http://taskfile.dev)
RUN sh -c "$(curl -ssL https://taskfile.dev/install.sh)" -- -d

# Prepare directories and volumes
RUN mkdir /output
ADD ./scripts /scripts
ADD ./config /config

VOLUME /config
VOLUME /output

ENTRYPOINT tail -f /dev/null