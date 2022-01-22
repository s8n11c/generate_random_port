#!/usr/bin/bash

#
# a bash script used for generating new random port and save it into a file named ".port_mapping"
# this file is used to store the port mapping between the container and the host
# 

branch_name=$1
action=$2 # this is suppose to be the action  (ADD or DEL) default is ADD

if [ -z $2 ]; then
    action="ADD"
fi


MAP_LOCATION=~/.port_mapping


mapping_existed=1


generate_port () {
    read LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
    while :
    do
            PORT="`shuf -i $LOWERPORT-$UPPERPORT -n 1`"
            ss -lpn | grep -q ":$PORT " || break
    done
    echo  $PORT
}

if [[ -f "$MAP_LOCATION" ]]; then
    mapping_existed=1
else 
    mapping_existed=0
fi



if [[ $mapping_existed -eq 1 ]] && [[ $action == 'ADD' ]]; then
    # read mapping file
    while read line
    do
        if [[ $line == *"$branch_name"* ]]; then
            # echo the port number 
            echo $line | awk '{print $2}'
            exit 1;
        fi
    done < $MAP_LOCATION


    # check if port existed
        # generate new port
    port="$(generate_port)"
    echo "$port"
    # write to mapping file
    echo "$branch_name $port" >> $MAP_LOCATION
    exit 1;
fi

if [[ $mapping_existed -eq 0 ]] && [[ $action -eq 'ADD' ]; then
    # generate new port
    port="$(generate_port)"
    echo "$port"
    # write to mapping file
    echo "$branch_name $port" >> $MAP_LOCATION
    exit 1;
fi  



if [[ $mapping_existed -eq 1 ]] && [[ $action -eq 'DEL' ]]; then
    # remove branch from mapping file 

    echo "removing"
    sed -i "/$branch_name/d" $MAP_LOCATION
    exit 1;
fi  