#!/bin/bash

# which machine we are deploying the distributed simulator
deploymentmachine=$1

# Owner of the remote machine
machineuser=$2

# Directory of deployment, this is place where all the necessary
# files are copying
deploymentdir=$3

# where is source path for simulator
resourcepath=$4

# Each simulator should simulatr unique jobs and nodes
jobsuffix=$5

# which RM each simulators are connecting
rmaddress=$6

# which RT is simulator is connecting
rtaddress=$7

# Get the ip address of the machine,

if [ "$rmaddress" == "ALL" ]
 then
  rmip="0.0.0.0"
  rtip="0.0.0.0"
  else
  rmip=$(getent hosts $rmaddress | awk '{ print $1 }')
  rtip=$(getent hosts $rtaddress | awk '{ print $1 }') 
 fi


yarnsitexml="$resourcepath/hadoop-tools/distributedLoadSimulator/distributedsimulator_resources/yarn-site.xml"

## lets delete the previous directory
#ssh $machineuser@$deploymentmachine "rm -rf $deploymentdir/distributedsimulator_resources"

## copy the fresh content
ssh $machineuser@$deploymentmachine "mkdir  $deploymentdir/distributedsimulator_resources"


linenumber=$(grep -n  "yarn.resourcemanager.address" $yarnsitexml | awk '{print $1}'| sed 's/.$//')
lineco=$((linenumber+1))
awk -v line=$lineco -v new_content="    <value>$rmip:25001</value>" '{
        if (NR == line) {
            print new_content 
                
        } else {
                print $0;
        }
}' $yarnsitexml >> tmp1.txt

linenumber=$(grep -n  "yarn.resourcemanager.scheduler.address" $yarnsitexml | awk '{print $1}'| sed 's/.$//')
lineco=$((linenumber+1))
awk -v line=$lineco -v new_content="    <value>$rmip:25003</value>" '{
        if (NR == line) {
            print new_content 
                
        } else {
                print $0;
        }
}' tmp1.txt >> tmp2.txt



linenumber=$(grep -n  "yarn.resourcemanager.resource-tracker.address" $yarnsitexml | awk '{print $1}'| sed 's/.$//')
lineco=$((linenumber+1))
awk -v line=$lineco -v new_content="    <value>$rtip:25005</value>" '{
        if (NR == line) {
            print new_content 
                
        } else {
                print $0;
        }
}' tmp2.txt >> tmp3.txt


rm $yarnsitexml
mv tmp3.txt $resourcepath/hadoop-tools/distributedLoadSimulator/distributedsimulator_resources/yarn-site.xml
rm tmp1.txt tmp2.txt





scp -r $resourcepath/hadoop-tools/distributedLoadSimulator/distributedsimulator_resources/* $machineuser@$deploymentmachine:$deploymentdir/distributedsimulator_resources

scp -r $resourcepath/hadoop-tools/distributedLoadSimulator/target/distributedLoadSimulator-2.4.0.jar $machineuser@$deploymentmachine:$deploymentdir/distributedsimulator_resources

jobfilename="sls-jobs_"
jobfilename+=$jobsuffix
jobfilename+=".json"


nodefilename="sls-nodes_"
nodefilename+=$jobsuffix
nodefilename+=".json"

#for nm in {1000..1000..1000}
#do
#   ssh $machineuser@$deploymentmachine "mkdir  $deploymentdir/distributedsimulator_resources/tracefiles/" 
#ssh $machineuser@$deploymentmachine "mkdir  $deploymentdir/distributedsimulator_resources/tracefiles/$nm"
#scp -r $resourcepath/hadoop-tools/DistributedLoadSimulator/simulator_tracefiles/$nm/$jobfilename $machineuser@$deploymentmachine:$deploymentdir/distributedsimulator_resources/tracefiles/$nm/sls-jobs.json
#scp -r $resourcepath/hadoop-tools/DistributedLoadSimulator/simulator_tracefiles/$nm/$nodefilename $machineuser@$deploymentmachine:$deploymentdir/distributedsimulator_resources/tracefiles/$nm/sls-nodes.json
#done
