rm -rf openshift-applier

rm -rf blue-green-spring

#git clone https://github.com/redhat-cop/casl-ansible.git
git clone https://github.com/redhat-cop/openshift-applier
git clone https://github.com/redhat-cop/container-pipelines.git

mv container-pipelines/blue-green-spring/ .

rm -rf container-pipelines

grep -rL "jenkins//ose-ephemeral" blue-green-spring | xargs sed -i 's/openshift\/\/jenkins-ephemeral/jenkins\/\/jenkins-ose/g'

grep -rl "malacourse" blue-green-spring | xargs sed -i 's/malacourse/dwaiba/g'
grep -rl "pabrahamsson" blue-green-spring | xargs sed -i 's/pabrahamsson/dwaiba/g'

ansible-playbook -i blue-green-spring/inventory/hosts openshift-applier/playbooks/openshift-cluster-seed.yml --connection=local


oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-build:default \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-dev:default \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-prod:default \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-stage:default \
    --namespace=jenkins

oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-build:builder \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-dev:builder \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-prod:builder \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-stage:builder \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-build:deployer \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-dev:deployer \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-prod:deployer \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-stage:deployer \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-build:jenkins \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-dev:jenkins \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-prod:jenkins \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-stage:jenkins \
    --namespace=jenkins
