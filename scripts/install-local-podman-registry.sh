#!/bin/bash
#https://www.redhat.com/sysadmin/simple-container-registry#:~:text=Push%2Fpull%20images%20to%20the%20registry&text=To%20push%20to%20the%20registry,and%20then%20push%20the%20image.&text=With%20the%20private%20registry%20implemented,the%20list%20of%20supported%20registries.
#https://stackoverflow.com/questions/64814173/how-do-i-use-sans-with-openssl-instead-of-common-name
#https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
sudo sh -c 'echo "insecure = false" >> /etc/containers/registries.conf'
sudo systemctl restart containerd
sudo systemctl status containerd
sudo apt-get update -y
sudo apt-get install -y apache2-utils p11-kit
sudo mkdir -p /opt/registry/{auth,certs,data}
sudo htpasswd -bBc /opt/registry/auth/htpasswd registryuser registryuserpassword
sudo openssl req -newkey rsa:4096 -nodes -sha256 -keyout /opt/registry/certs/domain.key -x509 -subj "/C=AU/ST=Denial/L=Springfield/O=Dis/CN=master-node" -days 365 -addext "subjectAltName = DNS:master-node" -out /opt/registry/certs/domain.crt
sudo cp /opt/registry/certs/domain.crt /usr/local/share/ca-certificates/
sudo mkdir /etc/containers/certs.d
sudo mkdir /etc/containers/certs.d/master-node:5000
sudo cp /opt/registry/certs/domain.crt /etc/containers/certs.d/master-node:5000/ca.crt
sudo update-ca-certificates
exit
sudo podman run --name myregistry \
       -p 5000:5000 \
       -v /opt/registry/data:/var/lib/registry:z \
       -v /opt/registry/auth:/auth:z \
       -e "REGISTRY_AUTH=htpasswd" \
       -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
       -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
       -v /opt/registry/certs:/certs:z \
       -e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt" \
       -e "REGISTRY_HTTP_TLS_KEY=/certs/domain.key" \
       -e REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true \
       -d \
       docker.io/library/registry:latest

podman login -u registryuser -p registryuserpassword master-node:5000
kubectl create secret generic regcred \
        --from-file=.dockerconfigjson=/run/user/1000/containers/auth.json \
        --type=kubernetes.io/dockerconfigjson
# and then specify the following in the pod deployment
#imagePullSecrets:
#- name: regcred
exit
cd /home/vagrant/testfiles/myrocks-sysbench
./build.sh
podman image tag localhost/myrocks-sysbench:latest master-node:5000/repo/myrocks-sysbench:latest
podman image push master-node:5000/repo/myrocks-sysbench:latest
