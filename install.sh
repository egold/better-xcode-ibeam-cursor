#!/usr/bin/env bash

# Constants
GITHUB_URL="https://raw.githubusercontent.com/egold/better-xcode-ibeam-cursor/master"
GITHUB_PATCHES_PATH="patches"
TMP_PATH="/tmp"
IBEAM_TIFF_FILENAME="DVTIbeamCursor.tiff"
ASSETS_CAR_FILENAME="Assets.car"
BACKUP_FILENAME_PREFIX="backup-"

XCODE_7_3_ASSETS_CAR_ORIGINAL_SHA="8e362f0cd2ee6306908b5275a721373ce8451a39"
XCODE_7_3_ASSETS_CAR_PATCH_FILENAME="Assets.car-Xcode-7.3.bspatch"
XCODE_7_3_ASSETS_CAR_PATCH_SHA="f5897929a05cf5f17ce9b31e2360afe2d6b5f7fe"
XCODE_7_3_ASSETS_CAR_PATCHED_SHA="33c3b358988a25907f181640b8baef3ab603d7c2"

XCODE_7_3_1_ASSETS_CAR_ORIGINAL_SHA="b9b12ffcbf0be9a8fbbaa043a90cd0317f4a316d"
XCODE_7_3_1_ASSETS_CAR_PATCH_FILENAME="Assets.car-Xcode-7.3.1.bspatch"
XCODE_7_3_1_ASSETS_CAR_PATCH_SHA="855263f05cb6111e4f91cec3464e479124665a26"
XCODE_7_3_1_ASSETS_CAR_PATCHED_SHA="2da32d5b87a2d16d5cc4d49922a517ae32e3cc77"

DVTIBEAM_CURSOR_TIFF_SHA="4b9d55d84e05cb1dff0815acc0a548f40bf8da27"

function update_cursor_for_xcode() {
    # Is Xcode found at the expected path?
    if [ -d "${xcode_path}" ]; then
        #   Yes. Continue.
        echo "Updating I-beam cursor for Xcode at path ${xcode_path}"

        determine_required_patch_file_for_xcode
        if [ ! $file_to_download = "" ]; then

            download_patch_file
            if [ -e "${download_destination_path}" ]; then

                backup_original_file
                if [ -e "${xcode_path}/${backup_file}" ]; then

                    apply_patch
                fi
            fi
        fi
    else
        #   No. Display a message if appropriate, then quit.
        if [ $show_failure_msg = true ]; then echo "Xcode not found at path ${xcode_path}"; fi
    fi
}

function determine_required_patch_file_for_xcode() {
    replace_file_mode=false
    file_to_download=""

    # Determine which patch file do we need.
    #   Does the Assets.car file exist?
    if [ -e "${xcode_path}/${ASSETS_CAR_FILENAME}" ]; then
        #     Yes. Confirm its SHA matches the original file that ships with Xcode 7.3. Does it match?
        sha=($(shasum "${xcode_path}/${ASSETS_CAR_FILENAME}"))
        if [ $sha = $XCODE_7_3_ASSETS_CAR_ORIGINAL_SHA ]; then
            #       Yes. We need the patch file for it.
            file_to_download=$XCODE_7_3_ASSETS_CAR_PATCH_FILENAME
            file_to_download_expected_sha=$XCODE_7_3_ASSETS_CAR_PATCH_SHA
            patched_file_expected_sha=$XCODE_7_3_ASSETS_CAR_PATCHED_SHA
        elif [ $sha = $XCODE_7_3_1_ASSETS_CAR_ORIGINAL_SHA ]; then
            file_to_download=$XCODE_7_3_1_ASSETS_CAR_PATCH_FILENAME
            file_to_download_expected_sha=$XCODE_7_3_1_ASSETS_CAR_PATCH_SHA
            patched_file_expected_sha=$XCODE_7_3_1_ASSETS_CAR_PATCHED_SHA
        else
            #       No. The file may have already been patched. Display a message, then return.
            if [ $sha = $XCODE_7_3_ASSETS_CAR_PATCHED_SHA ]; then
                echo "The patch has already been applied."
            elif [ $sha = $XCODE_7_3_1_ASSETS_CAR_PATCHED_SHA ]; then
                echo "The patch has already been applied."
            else
                echo "File checksum mismatch."
                echo "${ASSETS_CAR_FILENAME} - ${sha}"
                echo "Patch cannot be applied."
            fi
        fi
    else
        #     No. Does the DVTIbeamCursor.tiff file exist?
        if [ -e "${xcode_path}/${IBEAM_TIFF_FILENAME}" ]; then
            #   Yes. We need the replacement file for it. We're going to be replacing the file rather than patching.
            replace_file_mode=true
            file_to_download=$IBEAM_TIFF_FILENAME;
            file_to_download_expected_sha=$DVTIBEAM_CURSOR_TIFF_SHA
            patched_file_expected_sha=$DVTIBEAM_CURSOR_TIFF_SHA
        else
            #     No. We have no file to patch. Is this a newer version of Xcode? Display a message, then return.
            echo "Unable to determine which file needs to be patched. Is this a newer version of Xcode?"
        fi
    fi
}

function download_patch_file() {
    # Prepare to download the required patch file.
    download_destination_path="${TMP_PATH}/${file_to_download}"
    # Delete any existing downloaded file using our download target name.
    if [ -e "${download_destination_path}" ]; then rm "${download_destination_path}"; fi
    # Download the patch file.
    noun="patch"
    download_url="${GITHUB_URL}/${GITHUB_PATCHES_PATH}"
    if [ $replace_file_mode = true ]; then
        noun="replacement"
        download_url="${GITHUB_URL}"
    fi
    echo "Downloading cursor ${noun} file to ${download_destination_path}"
    curl -o "${download_destination_path}" "${download_url}/${file_to_download}"
    # Does the downloaded file's SHA match what we were expecting?
    sha=($(shasum "${download_destination_path}"))
    if [ $sha = $file_to_download_expected_sha ]; then
        #   Yes. Continue.
        echo "Downloaded successfully."
    else
        #   No. The download has failed. Display a message, then quit.
        cleanup
        echo "Download failed."
    fi
}

function backup_original_file() {
    # Prepare to create a backup of Xcode's original file.
    original_file="${ASSETS_CAR_FILENAME}"
    if [ $replace_file_mode = true ]; then
        original_file="${IBEAM_TIFF_FILENAME}"
    fi
    backup_file="${BACKUP_FILENAME_PREFIX}${original_file}"
    # Does a backup file already exist?
    if [ -e "${xcode_path}/${backup_file}" ]; then
        #   Yes. Continue.
        echo "Backup file already exists."
    else
        #   No. Display a message. Create the backup.
        echo "Creating backup of ${original_file} -> ${backup_file}"
        sudo cp "${xcode_path}/${original_file}" "${xcode_path}/${backup_file}"
        if [ ! -e "${xcode_path}/${backup_file}" ]; then
            echo "Failed to create backup. Cannot continue."
            cleanup
        fi
    fi
}

function apply_patch() {
    # We are now ready to patch or replace Xcode's file. Apply the patch/replacement.
    if [ $replace_file_mode = true ]; then
        sudo rm "${xcode_path}/${original_file}"
        sudo mv "${download_destination_path}" "${xcode_path}/${original_file}"
    else
        sudo bspatch "${xcode_path}/${original_file}" "${xcode_path}/${original_file}" "${download_destination_path}"
    fi
    # Does the patched file's SHA match what we were expecting?
    sha=($(shasum "${xcode_path}/${original_file}"))
    if [ $sha = $patched_file_expected_sha ]; then
        #   Yes. Patch was successful. Display message, then continue.
        echo "Xcode has been patched successfully. Please restart Xcode and have fun!"
    else
        #   No. Patch failed. Delete patched file. Restore backup. Display message, then quit.
        echo "Failed to apply patch. :( Restoring backup."
        sudo rm "${xcode_path}/${original_file}"
        sudo cp "${xcode_path}/${backup_file}" "${xcode_path}/${original_file}"
    fi
    # Delete the downloaded patch file.
    cleanup
}

function cleanup() {
    if [ -e "${download_destination_path}" ]; then rm "${download_destination_path}"; fi
}

# --- Main ---

# Install for standard Xcode installation.
show_failure_msg=true
xcode_path="/Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Resources"
update_cursor_for_xcode

# Install for beta Xcode installation, if found.
show_failure_msg=false
xcode_path="/Applications/Xcode-beta.app/Contents/SharedFrameworks/DVTKit.framework/Resources"
update_cursor_for_xcode

# Done!
