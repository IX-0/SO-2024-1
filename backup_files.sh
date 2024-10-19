#!/bin/bash

# leaving the functions for the flags here, will change later.


backup(){
    if [[] ! -d $1 ]];then
        echo "no such work diretory to backup"; #If workdir doesnt exist, exit immediatly
        exit 1 # function failed
    fi
    cd $1;
    copied=0;
    updated=0;
    warnings=0;
    for file in *;do
        if [[ -e "$2/$file" ]];then
            if [[ $file -nt $2/$file ]];then
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

checkRegex(){
    regex_pattern="$1"
    filename="$2"
    if [[ $filename =~ $regex_pattern ]]
        exit 0; #sucess, get it using '$?'
    fi
    exit 1; #failed
}
# is there a better way than to check for each file if regex_pattern matches its name?
#  find /path/to/dir -type f | grep -E '^[a-zA-Z0-9_-]+\.txt$'
#  returns the pathnames of files that match the regex_pattern. Might not be the best option, seeing we still 
#  need to iterate over files anyways. 
#  In 500 files, if only one matches the pattern, i see it being better. idk

excludeFiles(){ #check if it is in the list? 
#are we supposed to delete files that are in the list and also already in the backup diretory?
               

}

if [[ "$1" == '-c' ]]; then
    checking
    backup "$2" "$3"
else
    backup "$1" "$2"
fi
