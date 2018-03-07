#FROM openshift/jenkins-2-centos7
FROM jenkins/jenkins

USER root

COPY plugins.txt /tmp
RUN /usr/local/bin/install-plugins.sh /tmp/plugins.txt

# Install own maven since the maven packaged by CentOS is ancient
#COPY apache-maven-bin.tar.gz /tmp/apache-maven-bin.tar.gz
#RUN mkdir /opt/apache-maven && \
#    tar xzf /tmp/apache-maven-bin.tar.gz --strip-components 1 -C /opt/apache-maven && \
#    ln -s /opt/apache-maven/bin/mvn /usr/local/bin/mvn

# Removes OpenShift's sample job
RUN rm -rf /opt/openshift/configuration/jobs

