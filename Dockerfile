FROM ubuntu:18.04
LABEL maintainer="Cryptape Technologies <contact@cryptape.com>"

RUN apt-get update \
    && apt-get install -y rabbitmq-server \
                          python3-pip \
                          capnproto \
                          libsnappy-dev \
                          libgoogle-perftools-dev \
                          libssl-dev \
                          libsodium* \
                          libsecp256k1-dev \
                          pkg-config \
                          git \
                          curl \
                          libcurl4 \
                          sysstat \
                          sudo \
                          ca-certificates \
    && cd .. \
    && rm -rf /var/lib/apt/lists \
    && apt-get autoremove \
    && apt-get clean \
    && apt-get autoclean

RUN pip3 install -U pip \
     && hash pip3 \
     && pip3 install pysodium toml jsonschema secp256k1 protobuf requests ecdsa \
     jsonrpcclient[requests]==2.4.2 \
     py_solc==3.0.0 \
     simplejson==3.11.1 \
     pathlib==1.0.1 \
     pysha3>=1.0.2 \
     && pip3 install git+https://github.com/ethereum/pyethereum.git@3d5ec14032cc471f4dcfc7cc5c947294daf85fe0 \
     && rm -r ~/.cache/pip

RUN curl -o solc -L https://github.com/ethereum/solidity/releases/download/v0.4.24/solc-static-linux \
  && mv solc /usr/bin/ \
  && chmod +x /usr/bin/solc

COPY libgmssl.so.1.0.0 /usr/local/lib/
RUN ln -srf /usr/local/lib/libgmssl.so.1.0.0 /usr/local/lib/libgmssl.so
RUN ldconfig

# Link: https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/bin/gosu.asc \
    && rm /usr/bin/gosu.asc \
    && chmod +x /usr/bin/gosu

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

WORKDIR /opt/cita-run

RUN pip3 install -U bitcoin==1.1.42 

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
