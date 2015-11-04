#!/bin/bash
#./launchsimulator.sh /home/gautier/hop_distro bbc5 bbc1 bbc2 bbc4 bbc3:25001 bbc3 bbc3 5000
user="gautier"

basedir=$1
if [ -z "${basedir}" ]; then
    echo "Hadoop HOP distro dirctory can not be empty. <Ex : ./distributedsls.sh /home/sri/batchmode/hop_distro>"
    exit
fi
thisSimIp=$2
remoteSim1=$3
remoteSim2=$4
remoteSim3=$5
scp=$6
sc=$7
rt=$8
nm=${9}


## copy new sls-jobs and sls-node files in to both simulators
ssh $user@$remoteSim1 "cp $basedir/distributedsimulator_resources/tracefiles/sls-*.json $basedir/distributedsimulator_resources/output"
ssh $user@$remoteSim2 "cp $basedir/distributedsimulator_resources/tracefiles/sls-*.json $basedir/distributedsimulator_resources/output"
ssh $user@$remoteSim3 "cp $basedir/distributedsimulator_resources/tracefiles/sls-*.json $basedir/distributedsimulator_resources/output"
cp tracefiles/sls-*.json  output


for nm in {2000..20000..2000}
do


    echo "hadoop $nm" >> $basedir/hadoop-2.4.0/share/hadoop/tools/sls/simulationsDuration
    
    echo "================= Preparing the trace for node mangers - $nm ======================"


    for i in {1..5}
    do
        echo "[Simulation] going to simulate $nm number of node managers"
	
	echo "start rm"
	ssh $user@$sc "rm /home/gautier/hadoop//hadoop-2.4.0/logs/*"
	ssh $user@$sc "/home/gautier/hadoop/hadoop-2.4.0/sbin/yarn-daemon.sh start resourcemanager"
		
	sleep 5s
		

	echo "start simulators"
        ## start the remote resource manager
	echo "1"
        ssh $user@$remoteSim1 "cd $basedir/distributedsimulator_resources; ./initsimulator.sh $basedir output/sls-jobs_1_$i\_$nm.json output/sls-nodes_1_$i\_$nm.json $rt $scp $thisSimIp,$remoteSim2,$remoteSim3" &
	ssh $user@$remoteSim2 "cd $basedir/distributedsimulator_resources; ./initsimulator.sh $basedir output/sls-jobs_2_$i\_$nm.json output/sls-nodes_2_$i\_$nm.json $rt $scp $thisSimIp,$remoteSim1,$remoteSim3" &
	ssh $user@$remoteSim3 "cd $basedir/distributedsimulator_resources; ./initsimulator.sh $basedir output/sls-jobs_3_$i\_$nm.json output/sls-nodes_3_$i\_$nm.json $rt $scp $thisSimIp,$remoteSim1,$remoteSim2" &
	### start the simulator on this host
	echo "5"
        ./initsimulator.sh $basedir output/sls-jobs_0_$i\_$nm.json output/sls-nodes_0_$i\_$nm.json $rt $scp $remoteSim1,$remoteSim2,$remoteSim3 --isLeader --simulation-duration=600

        ### once this host experiments is done , kill the remote one too
        ssh $user@$remoteSim1 "cd $basedir/distributedsimulator_resources; ./killsimulator.sh"
	ssh $user@$remoteSim2 "cd $basedir/distributedsimulator_resources; ./killsimulator.sh"
	ssh $user@$remoteSim3 "cd $basedir/distributedsimulator_resources; ./killsimulator.sh"
        ## kill host simulator process
        ./killsimulator.sh

        ssh $user@$remoteSim1 "cp $basedir/hadoop-2.4.0/logs/yarn.log $basedir/distributedsimulator_resources/log_$i"
	ssh $user@$remoteSim2 "cp $basedir/hadoop-2.4.0/logs/yarn.log $basedir/distributedsimulator_resources/log_$i"
	ssh $user@$remoteSim3 "cp $basedir/hadoop-2.4.0/logs/yarn.log $basedir/distributedsimulator_resources/log_$i"
        cp $basedir/hadoop-2.4.0/logs/yarn.log $basedir/distributedsimulator_resources/log_$i


	echo "stop rm"
	ssh $user@$rt "/home/gautier/hadoop/hadoop-2.4.0/sbin/yarn-daemon.sh stop resourcemanager"
	ssh $user@$rt "mv /home/gautier/hadoop/hadoop-2.4.0/logs/*.log $basedir/hadoop-2.4.0/logs/sv/yarn_$i.log "
	
    done
done
