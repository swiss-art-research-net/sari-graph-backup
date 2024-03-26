FROM python:3.8

RUN apt-get -qq update && \
    apt-get -q -y upgrade && \
    apt-get install -y sudo curl wget locales && \
    rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8

RUN apt update
RUN apt install -y bison gtk-doc-tools
# Install Python packages
RUN pip install urllib3 requests tqdm sparqlwrapper PyYAML

# Install task runner (http://taskfile.dev)
RUN sh -c "$(curl -ssL https://taskfile.dev/install.sh)" -- -d

# Install Flex
RUN wget https://github.com/westes/flex/files/981163/flex-2.6.4.tar.gz ; tar xzf flex-2.6.4.tar.gz; rm flex-2.6.4.tar.gz
WORKDIR /flex-2.6.4
RUN ./configure
RUN make install
WORKDIR /

# Install Rapper
RUN wget https://download.librdf.org/source/raptor2-2.0.16.tar.gz
RUN tar xzf raptor2-2.0.16.tar.gz ; rm raptor2-2.0.16.tar.gz 
WORKDIR /raptor2-2.0.16
RUN ./autogen.sh
RUN ./configure
RUN make install
ENV LD_LIBRARY_PATH=/usr/local/lib
RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

# Prepare directories and volumes
RUN mkdir /output
ADD ./scripts /scripts
ADD ./config /config

VOLUME /config
VOLUME /output

ENTRYPOINT tail -f /dev/null