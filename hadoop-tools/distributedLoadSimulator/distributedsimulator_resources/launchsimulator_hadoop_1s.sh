#!/bin/bash
#./launchsimulator.sh /home/gautier/hop_distro bbc2 bbc3:25001 bbc3 bbc3 5000
user="gautier"

basedir=$1
if [ -z "${basedir}" ]; then
    echo "Hadoop HOP distro dirctory can not be empty. <Ex : ./distributedsls.sh /home/sri/batchmode/hop_distro>"
    exit
fi
thisSimIp=$2
scp=$3
sc=$4
rt=$5
nm=${6}


## copy new sls-jobs and sls-node files in to both simulators
echo "cp 5"
cp tracefiles/sls-*.json  output


for nm in {5000..5000..2000}
do


    echo "hadoop $nm" >> $basedir/hadoop-2.4.0/share/hadoop/tools/sls/simulationsDuration
    
    echo "================= Preparing the trace for node mangers - $nm ======================"


    for i in {1..1}
    do
        echo "[Simulation] going to simulate $nm number of node managers"

	echo "start rm"
	ssh $user@$sc "rm /home/gautier/hadoop//hadoop-2.4.0/logs/*"
	ssh $user@$sc "/home/gautier/hadoop/hadoop-2.4.0/sbin/yarn-daemon.sh start resourcemanager"
	
	sleep 5s
		

	echo "start simulators"
	### start the simulator on this host
	echo "5"
        ./initsimulator_1.sh $basedir output/sls-jobs_0_$i\_$nm.json output/sls-nodes_0_$i\_$nm.json $rt $scp --isLeader --simulation-duration=600

        ## kill host simulator process
        ./killsimulator.sh

        cp $basedir/hadoop-2.4.0/logs/yarn.log $basedir/distributedsimulator_resources/log_$i	

	echo "stop rm"
	ssh $user@$rt "/home/gautier/hadoop/hadoop-2.4.0/sbin/yarn-daemon.sh stop resourcemanager"
	ssh $user@$rt "mv /home/gautier/hadoop/hadoop-2.4.0/logs/*.log $basedir/hadoop-2.4.0/logs/sv/yarn_$i.log "
    done
done
