#!/bin/bash

backup(){
    if [ ! -d $1 ];then
        echo "no such work diretory to backup"; #If workdir doesnt exist, exit immediatly
        exit 1 # function failed
    fi
    cd $1;
    copied=0;
    updated=0;
    warnings=0;
    for file in *;do
        if [ -e "$2/$file" ];then
            if [ $file -nt $2/$file ];then
                cp -a $file "$2/$file";
                (( updated++ ));
            elif [[ $2/$file -nt $file ]]; then #throw warning
                echo "WARNING: backup entry $2/$file is newer than $file; SHould not happen"
                (( warnings++ ));
                continue; 
            fi
        else
            cp -a $file "$2/$file";
            (( copied++ ));
        fi 
    done;
    echo "While backuping $1: $warnings Warnings; $updated Updated; $copied Copied;" #idk if this should stay here or be used only on backup_summary.sh
}

# -c flag 
checking(){
    echo "Available commands:"
    echo "  [-c]          Check all available commands."
    echo "  [-b tfile]    Specify a text file containing a list of files/directories to exclude from the backup."
    echo "  [-r regexpr]  Only backup files that match the provided regular expression."
}
#In this version of the script, seeing that $0 is either -c or the workdir, this works perfectly. Verifying the order of the flags and args must be done in backup.sh though. And then combine it with these functions here.

if [ "$1" == '-c' ]; then
    checking
    backup "$2" "$3"
else
    backup "$1" "$2"
fi
