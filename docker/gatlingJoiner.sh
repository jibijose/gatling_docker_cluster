#!/bin/bash

PVC_DATA=/pvc-data
HOSTNAME=`hostname`

while true
do
	numofnodes=`ls -al /pvc-data | grep simulation | wc -l`
	if [ $numofns -eq 0 ]
    then

	fi
	echo `date`"   Waiting..."
	sleep 10
done
