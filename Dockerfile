FROM openshift/jenkins-2-centos7
USER root
COPY plugins.txt /tmp
RUN /usr/local/bin/install-plugins.sh /tmp/plugins.txt
RUN yum install -y wget
RUN wget http://apache.proserve.nl/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz && mv apache-maven-3.5.3-bin.tar.gz /tmp/apache-maven-bin.tar.gz
RUN mkdir /opt/apache-maven && \
    tar xzf /tmp/apache-maven-bin.tar.gz --strip-components 1 -C /opt/apache-maven && \
    ln -s /opt/apache-maven/bin/mvn /usr/local/bin/mvn
# Removes OpenShift's sample job
RUN rm -rf /opt/openshift/configuration/jobs


