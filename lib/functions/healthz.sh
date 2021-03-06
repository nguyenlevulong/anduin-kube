#!/usr/bin/env bash

INITIAL_DELAY=120
CHECK_INTERVAL=60
here=`cd $(dirname $BASH_SOURCE); pwd`

function checkAlive {
    echoLog "Checking alive"
    kubectl get service --all-namespaces=true --context minikube 2>/dev/null | sed 1d | awk '{print $2"."$1".svc.kube\t"$3}' | while read service; do
        echoLog "==> Checking $service"
        serviceName=`echo "$service" | cut -f 1`
        serviceIp=`echo "$service" | cut -f 2`
        ip=`$here/dns-lookup.py $service 2>/dev/null`
        if [ -z "$ip" ]; then
            echoLog "====> Failed"
            return 1
        elif [ "$ip" != "$serviceIp" ]; then
            echoLog "====> Mismatched ip, expected $serviceIp but got $ip"
            return 1
        else
            echoLog "====> Success: $ip"
        fi
    done
    echoLog "All services are alive"
    return 0
}

function tryFix {
    echoLog "Try fix"
    anduin-kube clear-cache
}

function healthz {
    if [ `whoami` != "root" ]; then
        echoLog "Must be root"
        exit 1
    fi
    echoLog "Healthz started"
    sleep $INITIAL_DELAY
    while true; do
        if ! checkAlive; then
            tryFix
        fi
        sleep $CHECK_INTERVAL
    done
}
