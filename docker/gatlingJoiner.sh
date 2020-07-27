#!/bin/bash

PVC_DATA=/pvc-data
HOSTNAME=`hostname`
NUM_OF_NODES=$1

while true
do
	numofnodes=`ls -al /pvc-data | grep simulation | wc -l`
	if [ $numofnodes == $NUM_OF_NODES ]
	then
		echo `date`"   Jobs completed in nodes $numofnodes"
		sleep 10
		break
	fi
	echo `date`"   Waiting... number of nodes completed $numofnodes out of expected $NUM_OF_NODES"
	sleep 10
done


while true
do
	echo `date`"   Waiting after completion..."
	sleep 10
done