# Fetch latest ubuntu layer
FROM wslph/ubuntu:xenial-latest
MAINTAINER Reynold E. Lariza <rey.lariza@whiteskylabs.com>

# Update ubuntu
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu xenial main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv 80F70E11F0F0D5F10CB20E62F5DA5F09C3173AA6 \
 && echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu xenial main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C \
 && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu xenial main" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get clean

# Download latest JDK 8

RUN apt-get install -y software-properties-common \
 && add-apt-repository ppa:webupd8team/java -y \
 && apt-get update \
 && apt-get install -y zip \
 && apt-get install -y curl \
 && apt-get install -y htop \
 && apt-get install -y jq \
 && echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
 && apt-get install -y oracle-java8-installer \
 && apt-get install oracle-java8-set-default \
 && apt-get clean
     
COPY assets/resources/ /opt/

# Define environment variables.

ENV MULE_HOME /opt/mule

# set the default environment
ENV MULE_ENV dev

# set the the app config to empty, to use /opt/mule/conf
ENV APP_CONFIG_PATH=

# set custom mule startup environment config
ENV MULE_STARTUP_ENV_CONFIG=

# use the default app, domain, and conf. 0 by default, Set this to 1 to override and use the external files.
ENV MULE_ENV_OVERRIDE_DEFAULT 0

ENV MULE_AGENT_UPDATE_URL=http://s3.amazonaws.com/mule-agent
ENV MULE_ARM_TOKEN=

# this will be used both by AMC and MMC for naming your Mule ESB.
ENV MULE_ESB_NAME=

# set the MMC environment variable
# e.g., http://mmc-host or https://mmc-host <-- /api/ wil be appended to target the MMC server
ENV MULE_MMC_URL= 

# Pass the authentication header (default value is Authorization:Basic YWRtaW46YWRtaW4=), which is the 
# encoded version of credential (admin/admin)
# this will be used first when specified, otherwise it will attempt to use the env variables (MULE_MMC_USERNAME, and MULE_MMC_PASSWORD) 
# for authentication
ENV MULE_MMC_HEADER_AUTH=

# or you can  pass the credentials
ENV MULE_MMC_USERNAME=
ENV MULE_MMC_PASSWORD=

# set the target server group name (e.g., Testing, Development, etc.)
# if this does not exist yet, it will be created if it does not exist yet.
ENV MULE_MMC_SERVER_GROUP=

# this is the hostname or IP address for http://<mmc-host>:<mmc-port>/mmc-support
ENV MULE_MMC_AGENT_HOST=

# port to be used by MMC agent, default is 7777
ENV MULE_MMC_AGENT_PORT=7777

# fetch mule esb runtime
RUN chmod 755 /opt/set-mule-repo.sh
RUN /opt/set-mule-repo.sh

# Define mount points.
VOLUME ["/opt/mule/logs", "/opt/mule/apps", "/opt/mule/domains", "/opt/mule/conf", "/opt/mule/patches"]

# Define working directory.
WORKDIR /opt/mule

# Configure (default ports) external access:

# Mule remote debugger
EXPOSE 5000

# Mule JMX port (must match Mule config file)
EXPOSE 1099

# Expose Jolokia port.
EXPOSE 8899
# Mule MMC agent port
EXPOSE $MULE_MMC_AGENT_PORT

CMD [ "/opt/mule/bin/mule-start.sh" ]