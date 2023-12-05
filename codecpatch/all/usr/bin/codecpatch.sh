#!/bin/ash

# https://github.com/wirgen/synocodectool-patch
# 06/2023

set -eo pipefail;
shopt -s nullglob;

#variables

bin_file="synocodectool"
conf_file="activation.conf"
conf_path="/usr/syno/etc/codec"
conf_string='{"success":true,"activated_codec":["hevc_dec","ac3_dec","h264_dec","h264_enc","aac_dec","aac_enc","mpeg4part2_dec","vc1_dec","vc1_enc"],"token":"123456789987654abc"}'
opmode="patchhelp"

declare -a binpath_list=()

#functions
print_usage() { 
printf "
SYNOPSIS
    patch.sh [-h] [-p|-r|-l]
DESCRIPTION
    Patch to enable transcoding without a valid serial in DSM 6+
        -h      Print this help message
        -p      Patch synocodectool
        -r      Restore from original from backup
        -l      List supported DSM versions
"
}
check_path () {
    for i in "${path_list[@]}"; do
        if [ -e "$i/$bin_file" ]; then
            binpath_list+=( "$i/$bin_file" )
        fi
    done
}

check_version () {
    local ver="$1"
    for i in "${versions_list[@]}" ; do
        [[ "$i" == "$ver" ]] && return 0
    done ||  return 1
}

list_versions () {
    for i in "${versions_list[@]}"; do
        echo "$i"
    done
    return 0
}

patch_menu() {
    local options=("$@")
    echo "Available binaries to patch/restore:"
    local PS3="Please choose which binary you want to patch/restore:"
    select option in "${options[@]}" "Quit"; do    
    if [[ $REPLY = "$(( ${#options[@]}+1 ))" ]] ; then
        echo "Goodbye"
        exit 0
    fi
    bin_path="$option"
    break
done
}

restore_menu() {
    local options=("$@")
    echo "Available backups to restore:"
    local PS3="Please choose which binary you want to restore to $bin_path:"
    select option in "${options[@]}" "Quit"; do    
    if [[ $REPLY = "$(( ${#options[@]}+1 ))" ]] ; then
        echo "Goodbye"
        exit 0
    fi
    backup_file="$option"
    break
done
}

patch_common () {
    source "/etc/VERSION"
    dsm_version="$productversion $buildnumber-$smallfixnumber"
    if [[ ! "$dsm_version" ]] ; then
        echo "Something went wrong. Could not fetch DSM version"
        exit 1
    fi

    echo "Detected DSM version: $dsm_version"

    if ! check_version "$dsm_version" ; then
        echo "Patch for DSM Version ($dsm_version) not found."
        echo "Patch is available for versions: "
        list_versions
        exit 1
    fi
    
    echo "Patch for DSM Version ($dsm_version) AVAILABLE!"    
    check_path
    
    if  ! (( ${#binpath_list[@]} )) ; then
        echo "Something went wrong. Could not find synocodectool"
        exit 1
    fi
    
    patch_menu "${binpath_list[@]}"
}

patch () {
    patch_common
    local backup_path="${bin_path%??????????????}/backup"
    local synocodectool_hash="$(sha1sum "$bin_path" | cut -f1 -d\ )"
    if [[ "${binhash_version_list[$synocodectool_hash]+isset}" ]] ; then
        local backup_identifier="${synocodectool_hash:0:8}"
        if [[ -f "$backup_path/$bin_file.$backup_identifier" ]]; then
            backup_hash="$(sha1sum "$backup_path/$bin_file.$backup_identifier" | cut -f1 -d\ )"
            if [[ "${binhash_version_list[$backup_hash]+isset}" ]]; then
                echo "Restored synocodectool and valid backup detected (DSM ${binhash_version_list[$backup_hash]}) . Patching..."
                echo -e "${binhash_patch_list[$synocodectool_hash]}" | xxd -r - "$bin_path"                
                echo "Patched successfully"
                echo "Creating spoofed activation.conf.."
                if [ ! -e "$conf_path/$conf_file" ] ; then
                    mkdir -p $conf_path
                    echo "$conf_string" > "$conf_path/$conf_file"
                    chattr +i "$conf_path/$conf_file"
                    echo "Spoofed activation.conf created successfully"
                    exit 0
                    else
                    chattr -i "$conf_path/$conf_file"
                    rm "$conf_path/$conf_file"
                    echo "$conf_string" > "$conf_path/$conf_file"
                    chattr +i "$conf_path/$conf_file"
                    echo "Spoofed activation.conf created successfully"
                    exit 0
                fi
            else
                echo "Corrupted backup and original synocodectool detected. Overwriting backup..."
                mkdir -p "$backup_path"
                cp -p "$bin_path" \
                "$backup_path/$bin_file.$backup_identifier"
                exit 0
            fi
        else    
            echo "Detected valid synocodectool. Creating backup.."
            mkdir -p "$backup_path"
            cp -p "$bin_path" \
            "$backup_path/$bin_file.$backup_identifier"
            echo "Patching..."
            echo -e "${binhash_patch_list[$synocodectool_hash]}" | xxd -r - "$bin_path"            
            echo "Patched"
            echo "Creating spoofed activation.conf.."
            if [ ! -e "$conf_path/$conf_file" ] ; then
                mkdir -p $conf_path
                echo "$conf_string" > "$conf_path/$conf_file"
                chattr +i "$conf_path/$conf_file"
                echo "Spoofed activation.conf created successfully"
                exit 0
            else
                chattr -i "$conf_path/$conf_file"
                rm "$conf_path/$conf_file"
                echo "$conf_string" > "$conf_path/$conf_file"
                chattr +i "$conf_path/$conf_file"
                echo "Spoofed activation.conf created successfully"
                exit 0
            fi
        fi
    elif [[ "${patchhash_binhash_list[$synocodectool_hash]+isset}" ]]; then
        local original_hash="${patchhash_binhash_list[$synocodectool_hash]}"
        local backup_identifier="${original_hash:0:8}"
        if [[ -f "$backup_path/$bin_file.$backup_identifier" ]]; then
            backup_hash="$(sha1sum "$backup_path/$bin_file.$backup_identifier" | cut -f1 -d\ )"
            if [[ "$original_hash"="$backup_hash" ]]; then
                echo "Valid backup and patched synocodectool detected. Skipping patch."
                exit 0
            else
                echo "Patched synocodectool and corrupted backup detected. Skipping patch."
                exit 1
            fi
        else
            echo "Patched synocodectool and no backup detected. Skipping patch."
            exit 1  
        fi
    else
            echo "Corrupted synocodectool detected. Please use the -r option to try restoring it."
            exit 1
    fi 
}

rollback () {
    patch_common
    local backup_path="${bin_path%??????????????}/backup"
    local synocodectool_hash="$(sha1sum "$bin_path" | cut -f1 -d\ )"
    if [[ "${patchhash_binhash_list[$synocodectool_hash]+isset}" ]] ; then
        local original_hash="${patchhash_binhash_list[$synocodectool_hash]}"
        local backup_identifier="${original_hash:0:8}"
        if [[ -e "$backup_path/$bin_file.$backup_identifier" ]] ; then
            local backup_hash="$(sha1sum "$backup_path/$bin_file.$backup_identifier" | cut -f1 -d\ )"
                if [[ "$original_hash" = "$backup_hash" ]]; then
                    cp -p "$backup_path/$bin_file.$backup_identifier" \
                    "$bin_path"
                    echo "Backup restored successfully (DSM ${binhash_version_list[$backup_hash]})"
                    exit 0
                else
                    echo "No valid backup found for patched synocodectool currently in use. You can download the original file for DSM ${binhash_version_list[$original_hash]}  from https://github.com/stl88083365/synocodectool-patch/."
                    exit 1
                fi
        else
            echo "No backups found for patched synocodectool currently in use. You can download the original file for DSM ${binhash_version_list[$original_hash]}  from https://github.com/stl88083365/synocodectool-patch/."
            exit 1
        fi
    elif [[ "${binhash_version_list[$synocodectool_hash]+isset}" ]]; then
        echo "Detected unpatched original synocodectool. Restoring not neccessary!"
        exit 0
    else
        echo "Detected corrupted synocodectool."
        local backup_files=( "$backup_path"/* )
        if (( ${#backup_files[@]} )); then
            restore_menu "${backup_files[@]}"
            echo "Checking Hash.."
            local backup_hash="$(sha1sum "$backup_file" | cut -f1 -d\ )"
            if [[ "${binhash_version_list[$backup_hash]+isset}" ]]; then
                cp -p "$backup_file" \
                "$bin_path"
                echo "Backup restored successfully (DSM ${binhash_version_list[$backup_hash]})"
                exit 0
            else
                echo "Not a valid backup. You can either try restoring another backup or download the original file for DSM $dsm_version from https://github.com/stl88083365/synocodectool-patch/."
                exit 1
            fi
        else
            echo "No backups found. You can download the original file for DSM $dsm_version from https://github.com/stl88083365/synocodectool-patch/."
            exit 1
        fi
    fi        
}

# Get updated patches
curl -L "https://raw.githubusercontent.com/wjz304/arpl-addons/main/codecpatch/patches" -o /tmp/patches
source /tmp/patches

#main()
if [ ! ${USER} = "root" ]; then
    echo "Please run as root"
    exit 1
fi

while getopts "prhl" flag; do
    case "${flag}" in
        p) opmode="patch";;
        r) opmode="patchrollback" ;;
        h) opmode="${opmode}" ;;
        l) opmode="listversions" ;;
        *) echo "Incorrect option specified in command line" ; exit 2 ;;
    esac
done

case "${opmode}" in
    patch) patch ;;
    patchrollback) rollback ;;
    patchhelp) print_usage ; exit 2 ;;
    listversions) list_versions ;;
    *) echo "Incorrect combination of flags. Use option -h to get help."
       exit 2 ;;
esac

exit 0
