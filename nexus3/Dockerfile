FROM  openjdk:8-jre-alpine
ENV NEXUS_VERSION 3.9.0-01

ENV SONATYPE_DIR /opt/sonatype
ENV NEXUS_HOME ${SONATYPE_DIR}/nexus3
ENV NEXUS_DATA /opt/nexus-data
ENV NEXUS_CONTEXT ''
ENV SONATYPE_WORK ${SONATYPE_DIR}/sonatype-work
user root

# install nexus
#RUN apk update && apk add openssl curl && rm -fr /var/cache/apk/*
#RUN echo http://nl.alpinelinux.org//mirrors/alpine/v3.7/main > /etc/apk/repositories; \
#    echo http://nl.alpinelinux.org/mirrors/alpine/v3.7/community >> /etc/apk/repositories
RUN apk update  && rm -fr /var/cache/apk/*
RUN apk --no-cache add openssl wget
RUN   apk update \
  &&   apk add ca-certificates wget \
  &&   update-ca-certificates  
RUN mkdir -p /opt/sonatype/ \
  && wget https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz -O - \
  | tar zx -C "${SONATYPE_DIR}" && rm -fr ${SONATYPE_WORK} \
  && mv "${SONATYPE_DIR}/nexus-${NEXUS_VERSION}" "${NEXUS_HOME}"

# configure nexus
RUN sed \
    -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' \
    -i ${NEXUS_HOME}/etc/nexus-default.properties

## create nexus user
RUN adduser -S -u 200 -D -H -h "${NEXUS_DATA}" -s /bin/false nexus3 nexus3

RUN mkdir -p "${NEXUS_DATA}/etc" "${NEXUS_DATA}/log" "${NEXUS_DATA}/tmp" "${SONATYPE_WORK}"
RUN ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3

## prevent warning: /opt/sonatype/nexus/etc/org.apache.karaf.command.acl.config.cfg (Permission denied)
RUN chown -R nexus3 /opt
RUN chown -R nexus3 "${NEXUS_HOME}"
RUN chown -R nexus3 "${SONATYPE_DIR}"

COPY entrypoint.sh /
RUN chown -R nexus3 "${NEXUS_DATA}"
RUN chmod +x /entrypoint.sh
RUN chown  nexus3 /entrypoint.sh


#VOLUME ${NEXUS_DATA}

EXPOSE 8081
WORKDIR ${NEXUS_HOME}

ENV JAVA_MAX_MEM 1200m
ENV JAVA_MIN_MEM 1200m
ENV EXTRA_JAVA_OPTS ""

ENTRYPOINT ["/entrypoint.sh"]
