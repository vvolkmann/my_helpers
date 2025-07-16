#!/bin/bash

# Usage example k8s_scale DEPLOY-NAME 6
function k_scale() {
    kubectl scale --replicas=${2} deploy/${1}
}
function k_pods_restart() {
    # List pods by restart count
    kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'
}

function k_watchpods() {
  watch -n30 -t 'echo -e "\nNotReady ($(kubectl get pods | grep -vE "NAME +READY|[1-9]/[1-9] + Running"|wc -l)):"; kubectl get pods | grep -vE "NAME +READY|[1-9]/[1-9] + Running" ;
           echo -e "\nReady ($(kubectl get pods | grep -E "[1-9]/[1-9] + Running"|wc -l)):"; kubectl get pods | grep -E "[1-9]/[1-9] + Running"'
}

function k_nodes_AZs() {
    for node in $(kubectl get nodes -o=jsonpath='{.items[*].metadata.name}'); do
        zone=$(kubectl get node $node -o json | jq '.metadata.labels."topology.cinder.csi.openstack.org/zone"')
        echo "$node - $zone"
    done
}

function k_nodes_details() {
    kubectl get nodes -o wide --no-headers | awk '{ print $1 " (" $2 ") \t" $5 " \t" $13 " \t" $12 " \t[" $3 "]"}'
}

function k_pods_byrestartcount() {
    kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'
}

function k_pods_bystarttime() {
    kubectl get pods --sort-by=.status.startTime
}
