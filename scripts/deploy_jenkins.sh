#!/bin/sh -xe

if [ -z "${GHORG}" ]; then
   GHORG=dwaiba
fi

if [ -z "${GHREF}" ]; then
   GHREF=master
fi

export GH_ORG=$GHORG
export GH_REF=$GHREF

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATES_DIR="$( cd $SCRIPTS_DIR/../templates && pwd )"

if [ -z "${RHNETWORK}" ]; then
   RHNETWORK=false
fi

if [ -z "${BUILD_MASTER}" ]; then
   BUILD_MASTER=false
fi

if [ -z "${BUILD_SLAVES}" ]; then
    BUILD_SLAVES=false
fi
if [ -z "${BUILD_NEXUS}" ]; then
   BUILD_NEXUS=false
fi

if [ -z "${NEXUS}" ]; then
   NEXUS=false
fi
if [ -z "${BUILD_SONAR}" ]; then
   BUILD_SONAR=false
fi

if [ -z "${SONAR}" ]; then
   SONAR=false
fi

if [ -z "${LIMITS}" ]; then
   LIMITS=true
fi

if [ -z "${ENABLE_OAUTH}" ]; then
   ENABLE_OAUTH=false
fi

oc new-project $PROJECT_NAME
#oc import-image custom-jenkins --from=dwaiba/jenkins-2-centos7-om-hosted --confirm --all


if [ -z "${DOCKER_USERNAME}" -o -z "${DOCKER_PASSWORD}"  -o -z "${DOCKER_EMAIL}" ]; then
    echo 'DOCKER_USERNAME and DOCKER_PASSWORD and DOCKER_EMAIL ENV variables should be provided' && exit 1
fi
oc secrets new-dockercfg dockerhub --docker-server=docker.io --docker-username=$DOCKER_USERNAME --docker-password=$DOCKER_PASSWORD --docker-email=$DOCKER_EMAIL
oc secrets link builder dockerhub

#for SLAVE in java-ubuntu jenkins-tools nodejs-ubuntu nodejs6-ubuntu ruby ruby-fhcap ansible go-centos7 python2-centos7 prod-centos7 nodejs6-centos7
for SLAVE in jenkins-tools prod-centos7 
do
    SLAVE_LABELS="$SLAVE ${SLAVE/-/ } openshift"

#    if [ "$SLAVE" = "nodejs-ubuntu" ] ; then
#        SLAVE_LABELS="ubuntu nodejs4-ubuntu"
#    fi
#
#    if [ "$SLAVE" = "nodejs6-ubuntu" ] ; then
#        SLAVE_LABELS="ubuntu nodejs6-ubuntu"
#    fi
#
#    if [ "$RHNETWORK" = true ] ; then
#    SLAVE_LABELS="$SLAVE_LABELS rhnetwork"
#    fi
    if [ "$BUILD_SLAVES" = true ] ; then
       oc new-app -p GITHUB_ORG=$GH_ORG -p GITHUB_REF=$GH_REF -p SLAVE_LABEL="$SLAVE_LABELS" -p CONTEXT_DIR=slave-$SLAVE -f $TEMPLATES_DIR/slave-build-template.yml
    else
       oc new-app -p SLAVE_LABEL="$SLAVE_LABELS" -p IMAGE_NAME=jenkins-slave-$SLAVE -f  $TEMPLATES_DIR/slave-image-template.yml
    fi
done

if [ "$LIMITS" = true ] ; then
    oc new-app -f  $TEMPLATES_DIR/resource-limits.yaml
fi

if [ "$BUILD_MASTER" = true ] ; then
    oc new-app -p GITHUB_ORG=$GH_ORG -p GITHUB_REF=$GH_REF -f  $TEMPLATES_DIR/jenkins-build-template.yaml
else
    oc new-app -f  $TEMPLATES_DIR/jenkins-image-template.yaml
fi
if [ "${ENABLE_OAUTH}" = true ]; then
  oc adm policy add-role-to-group view system:authenticated -n $PROJECT_NAME || echo "Adding view access for all users to this project failed. Users need this if they are to log-in."
fi

oc new-app -p ENABLE_OAUTH=$ENABLE_OAUTH -p MEMORY_LIMIT=4Gi -p NAMESPACE=$PROJECT_NAME -p JENKINS_IMAGE_STREAM_TAG=jenkins2-deb-ephemeral:latest -f  $TEMPLATES_DIR/jenkins-template.yml

if [ "$BUILD_NEXUS" = true ] ; then
    oc new-app -p GITHUB_ORG=$GH_ORG -p GITHUB_REF=$GH_REF -f  $TEMPLATES_DIR/nexus3-build-template.yaml
else
    oc new-app -f  $TEMPLATES_DIR/nexus3-image-template.yaml
fi

if [ "${NEXUS}" = true ]; then
oc new-app -p ENABLE_OAUTH=$ENABLE_OAUTH -p MEMORY_LIMIT=1Gi -p NAMESPACE=$PROJECT_NAME -p NEXUS_IMAGE_STREAM_TAG=nexusephemeral:latest -f  $TEMPLATES_DIR/nexus3-template.yaml
fi

if [ "$BUILD_SONAR" = true ] ; then
    oc new-app -p GITHUB_ORG=$GH_ORG -p GITHUB_REF=$GH_REF -f  $TEMPLATES_DIR/sonarqube-build-template.yaml
else
    oc new-app -f  $TEMPLATES_DIR/sonarqube-image-template.yaml
fi

if [ "${SONAR}" = true ]; then
oc new-app -p ENABLE_OAUTH=$ENABLE_OAUTH -p MEMORY_LIMIT=1Gi -p NAMESPACE=$PROJECT_NAME -p SONAR_IMAGE_STREAM_TAG=sonarqubeephemeral:latest -f  $TEMPLATES_DIR/sonarqube-template.yaml
fi


