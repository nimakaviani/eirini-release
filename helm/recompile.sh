#! /bin/bash

set -ex

APP="${1:-dora}"

helm dependency update cf/
../docker/generate-docker-image.sh latest
docker push nimak/opi:latest

SECRET=$(kubectl get pods --namespace uaa -o jsonpath='{.items[?(.metadata.name=="uaa-0")].spec.containers[?(.name=="uaa")].env[?(.name=="INTERNAL_CA_CERT")].valueFrom.secretKeyRef.name}')
CA_CERT="$(kubectl get secret $SECRET --namespace uaa -o jsonpath="{.data['internal-ca-cert']}" | base64 --decode -)"

helm upgrade scf cf --namespace scf --set "secrets.UAA_CA_CERT=${CA_CERT}" --values eirini/config/config.yml

kubectl get pods -n scf | grep eirini | awk '{print $1}' | xargs kubectl delete pod -n scf

cf d -f $APP
