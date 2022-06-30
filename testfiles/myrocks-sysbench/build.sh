#!/bin/bash
set -x

kubectl get secret regcred
regcredActive=$?
set -e
if [ $regcredActive -ne 0 ]; then
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
fi

podman build -t myrocks-sysbench .
podman image tag localhost/myrocks-sysbench:latest master-node:5000/repo/myrocks-sysbench:latest
podman image push master-node:5000/repo/myrocks-sysbench:latest
