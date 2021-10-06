#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

DEVICE=griffin
VENDOR=motorola

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}"/../../..

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

SECTION=
KANG=

while [ "$1" != "" ]; do
    case "$1" in
        -n | --no-cleanup )     CLEAN_VENDOR=false
                                ;;
        -k | --kang)            KANG="--kang"
                                ;;
        -s | --section )        shift
                                SECTION="$1"
                                CLEAN_VENDOR=false
                                ;;
        * )                     SRC="$1"
                                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in

        vendor/lib/libjustshoot.so)
            "${PATCHELF}" --add-needed libjustshoot_shim.so "${2}"
            ;;

        vendor/lib/libmmcamera2_sensor_modules.so)
            sed -i "s|/system/etc/camera/|/vendor/etc/camera/|g" "${2}"
            ;;

        vendor/lib/libmmcamera_vstab_module.so | vendor/lib/libmot_ois_data.so)
            "${PATCHELF}" --remove-needed libandroid.so "${2}"
            ;;

        vendor/lib/lib_mottof.so | vendor/lib/libmmcamera_vstab_module.so | vendor/lib/libjscore.so)
            sed -i "s/libgui/libwui/" "${2}"
            ;;

        vendor/lib/libcamerabgprocservice.so)
            "${PATCHELF}" --remove-needed libcamera_client.so "${2}"
            ;;

        vendor/lib/libcamerabgproc-jni.so)
            "${PATCHELF}" --remove-needed libandroid_runtime.so "${2}"
            "${PATCHELF}" --remove-needed libandroidfw.so "${2}"
            "${PATCHELF}" --remove-needed libmedia.so "${2}"
            "${PATCHELF}" --remove-needed libnativehelper.so "${2}"
            "${PATCHELF}" --add-needed libjni_shim.so "${2}"
            ;;

        vendor/lib/libjustshoot.so | vendor/lib/libjscore.so)
            "${PATCHELF}" --remove-needed libstagefright.so "${2}"
            ;;

        vendor/lib64/hw/gatekeeper.msm8996.so | vendor/lib64/hw/keystore.msm8996.so | vendor/lib64/lib_fpc_tac_shared.so | vendor/lib64/libSecureUILib.so)
            sed -i "s|/firmware/image|/vendor/f/image|g" "${2}"
            ;;

        vendor/lib/hw/camera.msm8996.so)
            sed -i "s|service.bootanim.exit|service.bootanim.hold|g" "${2}"
            ;;

        # memset shim
        vendor/bin/charge_only_mode)
            "${PATCHELF}" --add-needed "libmemset_shim.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files_griffin.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
