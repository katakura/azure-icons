#!/bin/bash
set -eu -o pipefail

DOWNLOAD_URL=https://arch-center.azureedge.net/icons/Azure_Public_Service_Icons_V15.zip
GENERATE_SIZE=(64 256 512)
ZIP_FILE_NAME=azure-icons.zip
TMP_DIR=./tmp
LIST_FILE=icon-files.csv
ICON_DIR=./icons

rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR}

# download original icon file
echo "### download original file"
curl -s -o ${TMP_DIR}/${ZIP_FILE_NAME} ${DOWNLOAD_URL}
sh -c "cd ${TMP_DIR}; unzip ${ZIP_FILE_NAME}" > /dev/null

# find target SVG files
echo "### generating list file"
rm -f ${TMP_DIR}/${LIST_FILE}
find ./tmp -name \*.svg -print | xargs -i sh -c "echo \`dirname \"{}\" | sed -r \"s/.+Icons\///g\" | sed \"s/ + /+/\" | sed \"s/ /_/g\" \`,\`basename \"{}\" | cut -d- -f4-100 | cut -d. -f1 | sed \"s/-/_/g\" | sed \"s/ //g\"\`,\"{}\"" >> ${TMP_DIR}/${LIST_FILE}

# convert SVG to PNG
for size in "${GENERATE_SIZE[@]}"; do
    echo "### generating ${size}px icons"

    while read line
    do
        category=$(echo ${line} | cut -d , -f 1)
        basename=$(echo ${line} | cut -d , -f 2)
        svgfile=$(echo ${line} | cut -d , -f 3)
        echo "-> ${ICON_DIR}/${size}px/${category}/${basename}.png"
        mkdir -p ${ICON_DIR}/${size}px/${category}
        inkscape -w ${size} "${svgfile}" --export-filename ${ICON_DIR}/${size}px/${category}/${basename}.png

    done < ${TMP_DIR}/${LIST_FILE}

done

# MEMO: zip -r Azure_Public_Service_Icons_V13_PNG.zip icons
