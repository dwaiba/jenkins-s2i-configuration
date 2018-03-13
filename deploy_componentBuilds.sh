oc delete serviceaccount jenkins nexus3 sonarqube -n openshift
oc delete rolebindings jenkins_edit sonarqube_edit nexus3_edit -n openshift
oc delete bc jenkins  nexus3 sonarqube -n openshift
oc delete dc jenkins  nexus3 sonarqube -n openshift
oc delete template jenkins-ose sonarqube-ose nexus3-ose -n openshift
oc delete service jenkins jenkins-jnlp nexus3 sonarqube -n openshift
oc delete route jenkins nexus3 sonarqube -n openshift
oc delete imagestream jenkins-2-centos7-ephemeral nexusephemeral sonarqubeephemeral -n openshift
PROJECT_NAME=openshift BUILD_MASTER=true  ENABLE_OAUTH=true BUILD_NEXUS=true NEXUS=true BUILD_SONAR=true SONAR=true ./scripts/deploy_jenkins.sh
