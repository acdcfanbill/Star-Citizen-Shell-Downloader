#!/bin/bash

# Shell test script by acdcfanbill
# no support or warranty provided, share freely

#set -x

# Settings
DEBUG=0
LIVE="Public_fileIndex"
PTU="Test_fileIndex"


# Check to see which release they want
echo "Please choose Public, or Test releases."
echo "Public is the Live release, Test is the PTU"
echo "Public - 1"
echo "Test   - 2"
echo "Exit   - other"
read release


# Pick the release we want
if [ "${release}" -eq 1 ]; then
    RELEASE=$LIVE
elif [ "${release}" -eq 2 ]; then
    RELEASE=$PTU
else
    exit
fi


# Lets get the current release info
JSONURL=`curl -s http://manifest.robertsspaceindustries.com/Launcher/_LauncherInfo | grep "${RELEASE}" | cut -d ' ' -f 3`
# Need to strip the extra carriage return so curl doesn't puke
JSONURL=${JSONURL%$'\r'}

if [ $DEBUG -ne 0 ]; then echo "JSON URL: ${JSONURL}"; fi

EXE="curl -s $JSONURL"
sleep 1

JSONCONTENTS=`$EXE`

if [ $DEBUG -ne 0 ]; then echo "JSON: ${JSONCONTENTS}"; fi

json="${JSONCONTENTS}"
prop="file_list"

FILEARRAY=`echo $JSONCONTENTS | awk 'match($0, /\"file_list": \[[^\]]*\]/) { print substr($0, RSTART, RLENGTH) }'`
PREFIX=`echo $JSONCONTENTS | awk 'match($0, /\"key_prefix\": \"[^\"]*\"/) { print substr($0, RSTART, RLENGTH) }' | sed 's/"key_prefix\": "//g' | sed 's/"//g'`

if [ $DEBUG -ne 0 ]; then echo -e "prefix: $PREFIX"; fi
if [ $DEBUG -ne 0 ]; then echo -e "file array:\n${FILEARRAY}"; fi

# Check to see if we have already downloaded this particular build
if [ -d ${PREFIX} ]; then
    echo "This build is either fully or partially downloaded.  Retry it? (y/n)"
    read result
    if [ "$result" = "y" ]; then
        echo "Continuing"
    else
        if [ "$result" == "n" ]; then
            #ignoring
            sleep 0
        else 
            echo "Bad option..."
        fi
        echo "Exiting..."
        exit
    fi
fi

# We are continuing, make the directory and change to it
mkdir -p $PREFIX
cd $PREFIX


# Lets turn ourarray of files into an actual list
TMPFILES=($FILEARRAY)
# if [ $DEBUG ]; then for i in "${TMPFILES[@]}"; do echo $i; done; fi
declare -a FILES
size=$((${#TMPFILES[@]}-1))
for((i=2;i<${size};i++))
do
    TMP=`echo ${TMPFILES[$i]} | tr -d ",$" | sed 's/"//g' `
    FILES+=(${TMP})
done

if [ $DEBUG -ne 0 ]; then echo file list: ${FILES[@]}; fi


# We could strip out the webseed link from the json too, but this shouldn't change
WEBSEED="http://1.webseed.robertsspaceindustries.com/"


# Now we can download each one.
WORKING_DIRECTORY=$PWD
count=0
max=${#FILES[@]}
for file in ${FILES[@]};
do
    count=$((count+1))
    dirpath=$(dirname $file)
    filename=$(basename $file)
    if [ $DEBUG -ne 0 ]; then echo "Currently doing..."; fi
    echo "File: $file (${count}/${max})"
    if [ $DEBUG -ne 0 ]; then echo "Filename: $filename"; fi
    if [ $DEBUG -ne 0 ]; then echo "Dirs: $dirpath"; fi

    # First, ensure the directories exist
    mkdir -p "${dirpath}"
    if [ $DEBUG -ne 0 ]; then
        pushd "${dirpath}"
        curl -C - -o "${filename}" "${WEBSEED}${PREFIX}/${file}"
        popd
    else
        pushd "${dirpath}" > /dev/null
        curl -s -C - -o "${filename}" "${WEBSEED}${PREFIX}/${file}"
        popd > /dev/null
    fi

done
