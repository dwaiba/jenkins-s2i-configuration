rm -rf openshift-applier

rm -rf blue-green-spring

#git clone https://github.com/redhat-cop/casl-ansible.git
git clone https://github.com/redhat-cop/openshift-applier
git clone https://github.com/redhat-cop/container-pipelines.git

mv container-pipelines/blue-green-spring/ .

rm -rf container-pipelines

grep -rl "openshift//jenkins-ephemeral" .| xargs sed -i 's/openshift\/\/jenkins-ephemeral/jenkins\/\/jenkins-ose/g'

grep -rl "pabrahamsson" .| xargs sed -i 's/pabrahamsson/dwaiba/g'
grep -rl "malacourse" .| xargs sed -i 's/malacourse/dwaiba/g'

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
    system:image-puller system:serviceaccount:spring-boot-web-build:spring-boot-web-build \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-dev:spring-boot-web-build \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-prod:spring-boot-web-build \
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
    system:image-puller system:serviceaccount:spring-boot-web-build:deployer \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-dev:deployer \
    --namespace=jenkins
oc policy add-role-to-user \
    system:image-puller system:serviceaccount:spring-boot-web-prod:deployer \
    --namespace=jenkins
