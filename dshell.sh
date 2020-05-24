#!/bin/bash

if [ -z $1 ]
  then
    mapfile -t names_array < <( docker ps --format "{{.Names}}" )

    #Prints the header
    printf "\n==================================================================================\n"
    printf "%s\t%s\n" "OPTION" "NAME"
    for i in "${!names_array[@]}"; do
	    printf "%d\t%s\n" $(( $i + 1 )) "${names_array[$i]}"
    done
    printf "==================================================================================\n"

    printf "\nSelect a container (0 to exit):\n"
    reg_ex="^[0-9]+$"
    array_lenght=${#names_array[@]}
    option=""
    while [[ ! "$option" =~ $reg_ex ]]; do
    	read option
      if [[ $option -lt 0 ]]
        then
        printf "Negative values are not allowed\n"
      elif [[ $option -gt $array_lenght ]]
      then
        printf "Invalid container option. Try again\n"
        option=""
      elif [[ $option -eq 0 ]]
      then
        printf "Exiting...\n"
      fi
    done
    
    if [[ $option -gt 0 && $option -le $array_lenght ]]
      then
      #Checks if the container has Bash available, if not, it uses sh (Alpine's containers don't have Bash)
      bashexists=$(docker exec ${names_array[$option - 1]} which bash)
      printf "\nEntering the shell of the container \"%s\"...\n" ${names_array[$option - 1]}
	    if [ ! -z $bashexists ]
	    then
      printf "\n------------------------------------- SHELL --------------------------------------\n"
        docker exec -i -t ${names_array[$option - 1]} /bin/bash
      printf '%s\n' "----------------------------------------------------------------------------------"
      else
        docker exec -i -t ${names_array[$option - 1]} /bin/sh
      fi
    else
      if [[ $option -ne 0 ]]
      then
        printf "Incorrect container"
      fi
    fi
else
    docker exec -i -t $1 /bin/bash
fi
