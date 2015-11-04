#!/bin/bash
# Author: Salman Niazi 2014



source deployment.properties

    #Build Hadoop
    CMD="mvn "	    
    if [ $HOP_Rebuild_HDFS = true ]; then
	    if [ $HOP_Do_Clean_Build = true ]; then
               CMD="$CMD clean "
	    fi	
	    
	    if [ $HOP_Build_offline = true ]; then
               CMD="$CMD -o "
	    fi	

            CMD="$CMD package -Pdist"  

	    if [ $HOP_Rebuild_HDFS_Native_Libs = true ]; then
               CMD="$CMD,native "  
            fi
            
            if [ $HOP_Skip_Java_Doc = true ]; then
               CMD="$CMD -Dmaven.javadoc.skip=true "
	    fi 	

            CMD="$CMD -DskipTests -Dtar -f $HOP_Src_Folder/pom.xml"  
	    echo $CMD
            $CMD
    fi


    #Build Experiments
    CMD="mvn "	    
    if [ $HOP_Rebuild_Experiments = true -a $HOP_Upload_Experiments = true ]; then
	    if [ $HOP_Do_Clean_Build = true ]; then
		    CMD="$CMD clean "
	    fi	
    	CMD="$CMD assembly:assembly -f $HOP_Experiments_Folder/pom.xml"  
	$CMD
    fi

   # echo "coping hop-metadata-dal-impl in hdfs project"
   # cp $HOP_Metadata_Dal_Impl_Folder/target/hop-metadata-dal-impl-ndb-1.0-HAYARN-SNAPSHOT-jar-with-dependencies.jar  $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/share/hadoop/hdfs/lib/

   # cp $HOP_Src_Folder/hop-leader-election/target/hop-leader-election-2.4.0* $HOP_Src_Folder/hadoop-dist/target/$Hadoop_Version/share/hadoop/hdfs/lib/
