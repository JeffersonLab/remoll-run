#!/bin/bash

printf "Remoll Platform\\n"

# display usage if no parameters are passed in
if [ $# -eq 0 ]
  then
    printf "usage: %s MACRO\\n" "$0"
    exit 0
fi

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

# download latest remoll image file
# TODO: determine if this will get a newer image if available
if ! singularity pull shub://JeffersonLab/remoll
then
    printf >&2 "Failed to download remoll image file.\\n"
    exit 1
fi

# get latest image file
latest=$(ls -t ./*remoll*.simg | head -n 1)

# create output directory
mkdir -p output

singularity run --bind "$(pwd)/output:/jlab/2.1/Linux_CentOS7.3.1611-x86_64-gcc4.8.5/remoll/rootfiles/" "$latest" "$absolutepath"
