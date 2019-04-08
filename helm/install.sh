#! /bin/bash

set -x

helm del scf --purge
helm del uaa --purge

kubectl delete ns uaa
kubectl delete ns scf

helm install uaa --namespace uaa --name uaa --values eirini/config/config.yml

while : ; do
    uaa_state=$(kubectl get pods -n uaa | grep uaa)
    if [[ $uaa_state =~ .*1/1.*Running.* ]]; then
        break
    fi
done
echo "finished"

SECRET=$(kubectl get pods --namespace uaa -o jsonpath='{.items[?(.metadata.name=="uaa-0")].spec.containers[?(.name=="uaa")].env[?(.name=="INTERNAL_CA_CERT")].valueFrom.secretKeyRef.name}')
CA_CERT="$(kubectl get secret $SECRET --namespace uaa -o jsonpath="{.data['internal-ca-cert']}" | base64 --decode -)"

helm install cf --namespace scf --name scf --set "secrets.UAA_CA_CERT=${CA_CERT}" --values eirini/config/config.yml
