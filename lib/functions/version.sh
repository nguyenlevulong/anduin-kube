#!/usr/bin/env bash

ANDUIN_KUBE_VERSION=0.7.8

function version {
    echo "anduin-kube version: $ANDUIN_KUBE_VERSION"
    minikube version
}
