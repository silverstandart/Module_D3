#!/bin/sh
# ---------------------------------------------------------------------------------------
#   Kubernates / 2022_05_17 / ANa
# ---------------------------------------------------------------------------------------

alias k=kubectl
alias m=minikube

m -p and5-main delete
k config view

echo -e "\n"

docker rm `docker ps -q -l`
docker image rm `docker image ls -q` -f
