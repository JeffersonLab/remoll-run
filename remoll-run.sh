#!/bin/bash

printf "Remoll runtime environment\\n"

# display usage if no parameters are passed in
if [ $# -eq 0 ]
  then
    printf "Usage: %s [-d|--debug] [-v|--verbose] [-u|--update] [-b <branch>|--branch <branch>] macro\\n" "$0"
    exit 0
fi

# define options
OPTIONS=b:dvu
LONGOPTIONS=branch:,debug,verbose,update

# getopt setup
getopt --test > /dev/null
if [[ $? -ne 4 ]]; then
    echo "Error: no getopt support on this system"
    exit 1
fi
# parse options
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt's output
eval set -- "$PARSED"

# now read options
while true; do
    case "$1" in
        -d|--debug)
            debug=y
            shift
            ;;
        -v|--verbose)
            verbose=y
            shift
            ;;
        -u|--update)
            update=y
            shift
            ;;
        -b|--branch)
            branch="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown option"
            exit 3
            ;;
    esac
done


# update the remoll-run.sh script itself
pushd `dirname $0` &> /dev/null
git fetch
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base HEAD @{u})
if [ $LOCAL != $REMOTE -a $LOCAL = $BASE ] ; then
    echo "An update to remoll-run is available. Run with -u option to update remoll-run. "
    if [ "$update" == "y" ] ; then
        git pull
    fi
fi
popd &> /dev/null


# expand relative path to macro to absolute path
absolutepath=$(pwd)/$1

# verify singularity is present
command -v singularity >/dev/null 2>&1 || {
    printf >&2 "remoll platform requires singularity.\\nGet singularity here: http://singularity.lbl.gov\\n"
    exit 1
}

# verify correct version of singularity
currentver="$(singularity --version)"
requiredver="2.4"
if [ "$(printf "%s\\n%s" "$requiredver" "$currentver" | sort -V | head -n1)" == "$currentver" ] && [ "$currentver" != "$requiredver" ]; then 
    printf >&2 "Found singularity %s, but remoll platform requires at least %s.\\n" "$currentver" "$requiredver"
    printf >&2 "Please upgrade your singularity: http://singularity.lbl.gov\\n"
    exit 1
fi

shub=shub://JeffersonLab/remoll

# download latest remoll image file
# TODO: determine if this will get a newer image if available
if ! singularity pull $shub
then
    printf >&2 "Failed to download remoll image file.\\n"
    exit 1
fi

# create output directory
mkdir -p rootfiles

binddirs=(
    '/site:/site'
    '/apps:/apps'
    '/cache:/cache'
    '/lustre:/lustre'
    '/volatile:/volatile'
    "$(pwd)/rootfiles:/jlab/2.1/Linux_CentOS7.3.1611-x86_64-gcc4.8.5/remoll/rootfiles/"
)

for i in "${binddirs[@]}"; do
    localbindpoint="$(echo -e "${i}" | sed -rn 's/^(\/.+):\/.*$/\1/p')"
    if [ -d "$localbindpoint" ]
    then
      echo "Binding $localbindpoint"
      bind="$bind --bind ${i}"
    fi
done
# trim leading whitespace from bind variable
bind="$(echo -e "${bind}" | sed -e 's/^[[:space:]]*//')"

# run singularity
singularity run $bind "$shub" "$absolutepath"
