#!/bin/bash

APPLICATIONS_PATH=/Applications
XCODE_APP_DIR_NAME=Xcode.app
XCODE_BETA_APP_DIR_NAME=Xcode-beta.app
XCODE_RESOURCE_PATH=Contents/SharedFrameworks/DVTKit.framework/Resources

XCODE_APP_PATH=$APPLICATIONS_PATH/$XCODE_APP_DIR_NAME/$XCODE_RESOURCE_PATH
XCODE_BETA_APP_PATH=$APPLICATIONS_PATH/$XCODE_BETA_APP_DIR_NAME/$XCODE_RESOURCE_PATH

IBEAM_TIFF_FILE=DVTIbeamCursor.tiff
ASSETS_CAR_FILE=Assets.car

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
    if [ -e "${xcode_path}/${IBEAM_TIFF_FILE}" ];
    then
        resource_file_name=$IBEAM_TIFF_FILE
    elif [ -e "${xcode_path}/${ASSETS_CAR_FILE}" ];
    then
        resource_file_name=$ASSETS_CAR_FILE
    else
        return -1
    fi

    echo "Downloading new cursor file"
    if [ -e "tmp/${resource_file_name}" ]; then rm "/tmp/${resource_file_name}"; fi

    curl -o "/tmp/${resource_file_name}" "https://raw.githubusercontent.com/egold/better-xcode-ibeam-cursor/master/${resource_file_name}"

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
    echo "Copying the improved ibeam cursor to the correct location"
    sudo cp "/tmp/${resource_file_name}" "${xcode_path}/${resource_file_name}"
}

function cleanup() {
    echo "Cleaning up"
    rm "/tmp/${resource_file_name}"
}

update_cursor_for_xcode $XCODE_APP_PATH true
update_cursor_for_xcode $XCODE_BETA_APP_PATH false

echo "Done - restart Xcode and have fun!"
