#!/bin/bash

backup(){
    cd $1;
    copied=0;
    updated=0;
    for file in *;do
        if [ -e "$2/$file" ];then
            if [ $file -nt $2/$file ];then
                cp -a $file "$2/$file";
                $(( updated++ ));
            else
                continue; 
            fi
        else
            cp -a $file "$2/$file";
            $(( copied++ ));
        fi 
    done;
    echo "$updated files updated, $copied files copied."
}
