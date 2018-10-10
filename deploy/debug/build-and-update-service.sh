#!/bin/bash

if  [ "${1}" == "" ] ||
    [ "${2}" == "" ] ||
    [ "${3}" == "" ]
then
    echo -e ""
    echo -e "\e[31mBad usage, please try:\033[0m\n${0} <NAMESPACE> <SERVICE> <BUILD_NUMBER>"
    echo -e "\n\033[0;32mExample:\033[0m\n${0} dev web test1245"
    exit 1
fi

start_time=`date`
namespace="${1}"
service="${2}"
build_number="${3}"
deploy_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

${deploy_folder}/docker/prepare build ${service} ${build_number} &&
${deploy_folder}/docker/prepare push ${service} ${build_number} &&
${deploy_folder}/kubernetes/templates/generate_rc_manifest ${service} ${namespace} ${build_number} &&
${deploy_folder}/clis/kubectl delete rc ${service} --namespace ${namespace}
${deploy_folder}/clis/kubectl create -f //root_directory/deploy/kubernetes/manifests/${service}-rc.yml

echo "sleep 10 seconds and will print status ..."
sleep 10
${deploy_folder}/kubernetes/describe ${namespace}

echo " "
echo -e "\e[34mservice: \033[0m ${service}-${build_number}"
echo -e "\e[34mstart:   \033[0m $start_time"
echo -e "\e[34mend:     \033[0m `date`"
echo " "
