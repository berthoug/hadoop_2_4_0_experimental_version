#!/bin/bash
# Author: Salman Niazi 2014
# This script broadcasts all files required for running a HOP instance.
# A password-less sign-on should be setup prior to calling this script


#check for installation of parallel-rsync
if [ ! -e /usr/bin/parallel-rsync ] ; then
echo "You do not appear to have installed: parallel-rsync"
echo "sudo aptitude install pssh"
exit
fi

#load config parameters
source deployment.properties

#build the distribution
source ./internals/build_distro.sh &&

#upload the distribution
if [ $HOP_Upload_Distro = true ]; then
    source ./internals/upload_distro.sh
fi

echo "################ Deploy the simulator ##################################"

deploymentdir=$(echo $HOP_Dist_Folder| sed 's/\/hadoop-.*//g')
uniqsimulatormachines=${SIMULATOR_MACHINES[*]}
alluniqsimulatormachines=$(echo "${uniqsimulatormachines[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
rmaddress=${SCHEDULER[0]}
rtaddress=${RESOURCE_TRACKERS[0]}
numberofmachine=0
for machinename in ${alluniqsimulatormachines[@]}
  do
  echo "$(tput setaf 1) Deploying on machine [$(tput sgr0) $(tput setaf 2) $machinename $(tput sgr0) $(tput setaf 1)] $(tput sgr0)"
  ./deploy_simulator.sh $machinename $HOP_User $deploymentdir $HOP_Src_Folder $numberofmachine $rmaddress $rtaddress
  numberofmachine=$((numberofmachine+1))
  done

## now let deploy on yarn macines


uniqyarnmachines=${YARN_MACHINES[*]}
alluniqyarnmachines=$(echo "${uniqyarnmachines[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

numberofmachine=0
for machinename in ${alluniqyarnmachines[@]}
  do
  echo "$(tput setaf 1) Deploying on machine [$(tput sgr0) $(tput setaf 2) $machinename $(tput sgr0) $(tput setaf 1)] $(tput sgr0)"
./deploy_simulator.sh $machinename $HOP_User $deploymentdir $HOP_Src_Folder $numberofmachine "ALL" "ALL"
  numberofmachine=$((numberofmachine+1))
  done




echo "################ Done #################################################"

exit 0



