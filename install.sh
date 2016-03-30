#!/bin/bash

APPLICATIONS_PATH=/Applications
XCODE_APP_DIR_NAME=Xcode.app
XCODE_BETA_APP_DIR_NAME=Xcode-beta.app
XCODE_RESOURCE_PATH=Contents/SharedFrameworks/DVTKit.framework/Resources

XCODE_APP_PATH=$APPLICATIONS_PATH/$XCODE_APP_DIR_NAME/$XCODE_RESOURCE_PATH
XCODE_BETA_APP_PATH=$APPLICATIONS_PATH/$XCODE_BETA_APP_DIR_NAME/$XCODE_RESOURCE_PATH

IBEAM_TIFF_FILE=DVTIbeamCursor.tiff
ASSETS_CAR_FILE=Assets.car

XCODE_7_3_ASSETS_CAR_SHA=8e362f0cd2ee6306908b5275a721373ce8451a39

GITHUB_URL=https://raw.githubusercontent.com/egold/better-xcode-ibeam-cursor/master
GITHUB_PATCHES_PATH=patches

function update_cursor_for_xcode() {
    xcode_path=$1
    show_failure_msg=$2

    if [ -d "${xcode_path}" ];
    then
        echo "Updating Xcode at path: ${xcode_path}"

        download_replacement_file
        backup_original_file
        install_replacement_file
        cleanup

    else
        if [ $show_failure_msg = true ]; then echo "Xcode not found at path: ${xcode_path}"; fi
    fi
}

function download_replacement_file() {
    patch_file=false
    if [ -e "${xcode_path}/${IBEAM_TIFF_FILE}" ]
    then
        resource_file_name=$IBEAM_TIFF_FILE
    elif [ -e "${xcode_path}/${ASSETS_CAR_FILE}" ]
    then
        resource_sha=`shasum "${xcode_path}/${ASSETS_CAR_FILE}" | awk 'BEGIN { FS = " " } ; { print $1 }'`
        resource_file_name="${ASSETS_CAR_FILE}-${resource_sha}.bspatch"
        patch_file=true
    else
        return -1
    fi

    if [ -e "tmp/${resource_file_name}" ]; then rm "/tmp/${resource_file_name}"; fi

    if [ $patch_file = true ]
    then
        echo "Downloading cursor patch"
        curl -o "/tmp/${resource_file_name}" "${GITHUB_URL}/${GITHUB_PATCHES_PATH}/${resource_file_name}"
    else
        echo "Downloading new cursor file"
        curl -o "/tmp/${resource_file_name}" "${GITHUB_URL}/${resource_file_name}"
    fi

    if [ ! -s "/tmp/${resource_file_name}" ]
    then
        rm "/tmp/${resource_file_name}"
        echo "Failed to download!"
        exit 1
    fi
}

function backup_original_file() {
    backup_resource_file_name="backup-${resource_file_name}"

    if [ -e "${xcode_path}/${backup_resource_file_name}" ]
    then
        echo "Backup file already exists: ${backup_resource_file_name}"
    else
        echo "Backing up the original cursor file that ships with Xcode to: ${backup_resource_file_name}"
        sudo cp "${xcode_path}/${resource_file_name}" "${xcode_path}/${backup_resource_file_name}"
    fi
}

function install_replacement_file() {
    if [ $patch_file = true ]
    then
        echo "Patching in the improved ibeam cursor"
        sudo bspatch "${xcode_path}/${ASSETS_CAR_FILE}" "${xcode_path}/${ASSETS_CAR_FILE}" "/tmp/${resource_file_name}"
    else
        echo "Copying the improved ibeam cursor to the correct location"
        sudo cp "/tmp/${resource_file_name}" "${xcode_path}/${resource_file_name}"
    fi
}

function cleanup() {
    echo "Cleaning up"
    rm "/tmp/${resource_file_name}"
}

update_cursor_for_xcode $XCODE_APP_PATH true
update_cursor_for_xcode $XCODE_BETA_APP_PATH false

echo "Done - restart Xcode and have fun!"
