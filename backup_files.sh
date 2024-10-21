#!/bin/bash     

    if [[] ! -d $1 ]];then
        echo "no such work diretory to backup"; #If workdir doesnt exist, exit immediatly
        exit 1;
    fi
    cd $1
    for file in *;do
        if [[ -e "$2/$file" ]];then
            if [[ $file -nt $2/$file ]];then
                cp -a $file "$2/$file";
            elif [[ $2/$file -nt $file ]]; then #throw warning
                echo "WARNING: backup entry $2/$file is newer than $file; SHould not happen"
                continue; 
            fi
        else
            cp -a $file "$2/$file";
        fi 
    done;



