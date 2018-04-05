oc project openshift-node
oc delete serviceaccount jenkins nexus3 sonarqube -n openshift-node
oc delete rolebindings jenkins_edit sonarqube_edit nexus3_edit -n openshift-node
oc delete bc jenkins  nexus3 sonarqube -n openshift-node
oc delete dc jenkins  nexus3 sonarqube -n openshift-node
oc delete template jenkins-ose sonarqube-ose nexus3-ose -n openshift-node
oc delete service jenkins jenkins-jnlp nexus3 sonarqube -n openshift-node
oc delete route jenkins nexus3 sonarqube -n openshift-node
oc delete imagestream jenkins-2-rhel74-ephemeral nexusephemeral sonarqubeephemeral -n openshift-node
PROJECT_NAME=openshift-node BUILD_MASTER=true  ENABLE_OAUTH=true BUILD_NEXUS=true NEXUS=true BUILD_SONAR=true SONAR=true ./scripts/deploy_jenkins.sh
