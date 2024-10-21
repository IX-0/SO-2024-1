#!/bin/bash

backup(){
    cd $1;
    for file in *;do
        lastModWorkdir=$(date -r "$file" +"%s");
        lastModDestdir=$(date -r "$file" +"%s");
        if [ "$lastModWorkdir" != "$lastModDestdir" ];then
            cp -a $file "$2/$file";
            echo "Copied $file to $2"
        fi
    done;
    

}
