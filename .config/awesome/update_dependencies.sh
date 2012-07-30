#!/bin/zsh
#===============================================================================
#          FILE:  update_dependencies.sh
#         USAGE:  ./update_dependencies.sh 
#   DESCRIPTION:  
#        AUTHOR: Kamil Essekkat kamil@essekkat.pl
#       CREATED: 30.07.2012 21:00:15 CEST
#===============================================================================

function git_export() {
    repo=$1
    destination=$2
    if [ -d $destination ]
    then
        mv ${destination} ${destination}.bak
    fi
    git clone ${repo} ${destination}
    rm -rf ${destination}/.git
}

##############
git_export 'https://github.com/bioe007/awesome-shifty.git' 'shifty'
