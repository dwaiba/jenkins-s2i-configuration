ansible-playbook -i inventory/hosts ../casl-ansible/playbooks/openshift-cluster-seed.yml --connection=local


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
