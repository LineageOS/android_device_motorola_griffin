#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright 2018 The LineageOS Project
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

# This contains the module build definitions for the hardware-specific
# components for this device.
#
# As much as possible, those components should be built unconditionally,
# with device-specific names to avoid collisions, to avoid device-specific
# bitrot and build breakages. Building a component unconditionally does
# *not* include it on all devices, so it is safe even with hardware-specific
# components.

LOCAL_PATH := $(call my-dir)

ifneq ($(filter griffin,$(TARGET_DEVICE)),)

include $(call all-makefiles-under,$(LOCAL_PATH))

include $(CLEAR_VARS)

# Create links for audcal data files
$(shell mkdir -p $(TARGET_OUT_VENDOR)/etc/firmware/wcd9320; \
	ln -sf /data/vendor/misc/audio/wcd9320_anc.bin \
		$(TARGET_OUT_VENDOR)/etc/firmware/wcd9320/wcd9320_anc.bin;\
	ln -sf /data/vendor/misc/audio/mbhc.bin \
		$(TARGET_OUT_VENDOR)/etc/firmware/wcd9320/wcd9320_mbhc.bin; \
	ln -sf /data/vendor/misc/audio/wcd9320_mad_audio.bin \
		$(TARGET_OUT_VENDOR)/etc/firmware/wcd9320/wcd9320_mad_audio.bin)


$(shell mkdir -p $(TARGET_OUT_ETC)/firmware; \
    ln -sf /dev/block/bootdevice/by-name/msadp \
        $(TARGET_OUT_ETC)/firmware/msadp)

#A/B builds require us to create the mount points at compile time.
#Just creating it for all cases since it does not hurt.
FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/firmware_mnt
BT_FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/bt_firmware
DSP_MOUNT_POINT := $(TARGET_OUT_VENDOR)/dsp
FSG_MOUNT_POINT := $(TARGET_OUT_VENDOR)/fsg

ALL_DEFAULT_INSTALLED_MODULES += $(FIRMWARE_MOUNT_POINT) \
	$(BT_FIRMWARE_MOUNT_POINT) \
	$(DSP_MOUNT_POINT) \
	$(FSG_MOUNT_POINT)

$(FIRMWARE_MOUNT_POINT):
	@echo "Creating $(FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/firmware_mnt
	@ln -sf /vendor/firmware_mnt $(TARGET_OUT_VENDOR)/f
ifneq ($(TARGET_MOUNT_POINTS_SYMLINKS),false)
	@ln -sf /vendor/firmware_mnt $(TARGET_ROOT_OUT)/firmware
endif

$(BT_FIRMWARE_MOUNT_POINT):
	@echo "Creating $(BT_FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/bt_firmware
ifneq ($(TARGET_MOUNT_POINTS_SYMLINKS),false)
	@ln -sf /vendor/bt_firmware $(TARGET_ROOT_OUT)/bt_firmware
endif

$(DSP_MOUNT_POINT):
	@echo "Creating $(DSP_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/dsp
ifneq ($(TARGET_MOUNT_POINTS_SYMLINKS),false)
	@ln -sf /vendor/dsp $(TARGET_ROOT_OUT)/dsp
endif

$(FSG_MOUNT_POINT):
	@echo "Creating $(FSG_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/fsg

DSP_SYMLINK := $(TARGET_OUT_VENDOR)/lib/dsp
$(DSP_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating DSP folder symlink: $@"
	@rm -rf $@
	$(hide) ln -sf /vendor/dsp $@

ALL_DEFAULT_INSTALLED_MODULES += $(DSP_SYMLINK)

MODS_LIBS := libmodhw.so
MODS_SYMLINKS := $(addprefix $(TARGET_OUT)/priv-app/ModFmwkProxyService/lib/arm64/,$(notdir $(MODS_LIBS)))
$(MODS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "MODS lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /system/lib64/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(MODS_SYMLINKS)

IMS_LIBS := libimscamera_jni.so libimsmedia_jni.so
IMS_SYMLINKS := $(addprefix $(TARGET_PRODUCT_OUT_ROOT)/priv-app/ims/lib/arm64/,$(notdir $(IMS_LIBS)))
$(IMS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "IMS lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /product/lib64/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(IMS_SYMLINKS)

BT_FIRMWARE := btfw32.tlv btnv32.bin btnv32.b15
BT_FIRMWARE_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR)/firmware/,$(notdir $(BT_FIRMWARE)))
$(BT_FIRMWARE_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating BT firmware symlink: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /bt_firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(BT_FIRMWARE_SYMLINKS)

RFS_MSM_ADSP_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/msm/adsp/
$(RFS_MSM_ADSP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM ADSP folder structure: $@"
	@rm -rf $@/*
	@mkdir -p $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/lpass $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/adsp $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

RFS_MSM_SLPI_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/msm/slpi/
$(RFS_MSM_SLPI_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM SLPI folder structure: $@"
	@rm -rf $@/*
	@mkdir -p $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/slpi $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/slpi $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

RFS_MSM_MPSS_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/msm/mpss/
$(RFS_MSM_MPSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM MPSS folder structure: $@"
	@rm -rf $@/*
	@mkdir -p $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/modem $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/mpss $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

ALL_DEFAULT_INSTALLED_MODULES += $(RFS_MSM_ADSP_SYMLINKS) $(RFS_MSM_MPSS_SYMLINKS) $(RFS_MSM_SLPI_SYMLINKS)

endif
