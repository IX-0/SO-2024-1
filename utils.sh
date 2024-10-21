#!/bin/bash

cpHelper(){

    backupdir=$(realpath "$2")
    workdir=$(realpath "$1")
    for file in $workdir
        do
        if [[ -e "$backupdir/$file" ]]
        then
            if [[ "$file" -nt "$backupdir/$file" ]]
            then
                echo "cp -a $file "$backupdir/$file""
                if ! $_checking
                then
                    cp -a $file "$backupdir/$file"
                fi
            else
                echo "WARNING: backup entry $2/$file is newer than $file; SHould not happen"
                continue
            fi
        else
            if ! $_checking
            then
                cp -a $file "$backupdir/$file"
            fi
            echo "cp -a $file "$backupdir/$file""
        fi 
    done

}

mkdirHelper(){
    echo "mkdir $2"
    if ! $_checking 
    then
        mkdir $2
    fi
}

removeHelper(){  #checks if there are files or diretories in backupdir that do not exist in workdir and rm them
    workdir=$(realpath "$1")
    backupdir=$(realpath "$2")
    for item in $backupdir
    do
        if [[-f "$item"]]
        then
            if [[! "$item" -f "$workdir" ]]
            then
                if ! $_checking
                then
                    rm $item
                fi
                echo "rm $item"
            fi
        else
            if [[ ! "$item" -d "$workdir" ]]
            then
                if ! $_checking
                then
                    rm -r $item
                fi    
                echo "rm -r $item"
            fi


}
