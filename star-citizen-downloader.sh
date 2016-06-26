#!/bin/bash

# Updated 20160626
#
# Shell test script by acdcfanbill, AntonLacon
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# Share freely.

#set -x

### START SETUP VARIABLES ###

PN="${0##*/}" # PackageName
DEBUG=0 # Verbose mode (default no)
CONTINUE_DL=0 # Continue download (default no)
RELEASE_FILEINDEX="Public_fileIndex" # Live/PTU release; override to PTU via cli arg (default Live)

### END SETUP VARIABLES ###
### START HELPER FUNCTIONS ###

# die(msg, code) echo an abort message, and use the exit code if provided
die() {
    echo "$1"
    if [ -n "$2" ]; then
        exit "$2"
    else
        exit 1
    fi
}

# help() echo usage message of program
help() {
    echo "Usage: "${PN}" [-htvy]"
        echo "Parameters left blank will use default or cause an abort showing this message."
        echo "  -h this help message"
        echo "  -t download the testing PTU release instead of Live (default=Live)"
        echo "  -v turn on verbose debugging messages (default=off)"
        echo "  -y continue previous download if found (default=no)"
}

### END HELPER FUNCTIONS ###
### COMMAND LINE ARGUMENT PARSER ###
while getopts htvy OPT; do
    case "${OPT}" in
        h)
            help && exit
            ;;
        t)
            RELEASE_FILEINDEX="Test_fileIndex"
            ;;
        v)
            DEBUG=1
            ;;
        y)
            CONTINUE_DL=1
            ;;
        \?)
            # abort on unknown argument
            help && die
            ;;
    esac
done

# Clear out switches
shift $((${OPTIND}-1))
### END COMMAND LINE ARGUMENT PARSER ###
### MAIN ###

# Lets get the current release info
JSONURL=$( wget -q -O - http://manifest.robertsspaceindustries.com/Launcher/_LauncherInfo | grep "${RELEASE_FILEINDEX}" | cut -d ' ' -f 3 | tr -d '\r')

if [ $DEBUG -ne 0 ]; then echo "JSON URL: ${JSONURL}"; fi

JSONCONTENTS=$( wget -q -O - "${JSONURL}" )

if [ $DEBUG -ne 0 ]; then echo "JSON: ${JSONCONTENTS}"; fi

FILEARRAY=$( echo $JSONCONTENTS | awk 'match($0, /\"file_list": \[[^\]]*\]/) { print substr($0, RSTART, RLENGTH) }' )
PREFIX=$( echo $JSONCONTENTS | awk 'match($0, /\"key_prefix\": \"[^\"]*\"/) { print substr($0, RSTART, RLENGTH) }' | sed -e 's/"key_prefix\": "//g' -e 's/"//g' )

if [ $DEBUG -ne 0 ]; then
    echo -e "prefix: ${PREFIX}\nfile array:\n${FILEARRAY}"
fi

# Check to see if we have already downloaded this particular build
if [[ -d "${PREFIX}" && "${CONTINUE_DL}" -ne 1 ]]; then
    echo "This build is either fully or partially downloaded.  Retry it? (y/n)"
    read result
    result="${result,,}" # convert result to lowercase
    while [[ "${result}" != "y" && "${result}" != "n" ]]; do
        echo "Unknown response. Continue download? (y/n)"
        read result
        result="${result,,}"
    done
    if [ "${result}" == "n" ]; then
        echo "Exiting" && exit
    fi
fi

# Convert JSONCONTENTS' file_array to a list of files for acting on
TMPFILES=($FILEARRAY)
# if [ $DEBUG ]; then for i in "${TMPFILES[@]}"; do echo $i; done; fi
declare -a FILES
size=$((${#TMPFILES[@]}-1))
for((i=2;i<${size};i++)); do
    TMP=$( echo ${TMPFILES[$i]} | tr -d ",$" | sed 's/"//g' )
    FILES+=(${TMP})
done

if [ $DEBUG -ne 0 ]; then echo file list: ${FILES[@]}; fi

# At present, CIG provides 64 webseeds, sequentially numbered.
# Select a webseed to download at random for each file.
NUMBER_OF_SEEDS=64

# Download each file sequentially.
count=0
max=${#FILES[@]}

echo "Downloading client..."
for file in ${FILES[@]}; do
    count=$((count+1))
    dirpath=$( dirname "${file}" )

    # $RANDOM is 0 - 32,767. Use modulo and add 1 as webseed counts from 1 not 0.
    RANDOM_SEED=$(( RANDOM%$NUMBER_OF_SEEDS+1 ))
    # Webseed link could be stripped from JSONCONTENTS, but this probably won't
    # change so hardcode the root.
    WEBSEED="http://${RANDOM_SEED}.webseed.robertsspaceindustries.com/"

    echo "File: $file (${count}/${max}) from server ${RANDOM_SEED}"

    # First, ensure the directories exist
    mkdir -p "${PREFIX}/${dirpath}" || die "failed to create an output directory"
    if [ $DEBUG -ne 0 ]; then
        wget -c -O "${PREFIX}/${file}" "${WEBSEED}${PREFIX}/${file}" || die "failed to download file"
    else
        wget -q -c -O "${PREFIX}/${file}" "${WEBSEED}${PREFIX}/${file}" || die "failed to download file"
    fi
done

# Job finished
exit
