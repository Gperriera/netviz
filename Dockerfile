FROM ubuntu:14.04

ARG NETVIZ_ZIP_PKG
RUN groupadd -r appd-netviz && useradd -r -g appd-netviz appd-netviz

RUN apt-get update && apt-get install -y \
  net-tools \
  tcpdump \
  curl  \
  unzip   \
  ssh-client \
  binutils \
  build-essential 

WORKDIR /netviz-agent

# copy NetViz agent contents
COPY $NETVIZ_ZIP_PKG .

# run the agent install script and disable netlib
RUN unzip $NETVIZ_ZIP_PKG && ./install.sh \
    && sed -i -e "s|enable_netlib = 1|enable_netlib = 0|g" ./conf/agent_config.lua \
    && sed -i -e "s|WEBSERVICE_IP=.*|WEBSERVICE_IP=\"0.0.0.0\"|g" ./conf/agent_config.lua

RUN chown -R appd-netviz:appd-netviz /netviz-agent
RUN setcap cap_net_raw=eip /netviz-agent/bin/appd-netagent
USER appd-netviz

# default command to run for the agent
CMD  ./bin/appd-netagent -c ./conf -l ./logs -r ./run
