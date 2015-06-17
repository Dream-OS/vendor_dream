ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/dream/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

PRODUCT_BOOTANIMATION := vendor/dream/predbuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/dream/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/dream/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/dream/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh \
    vendor/dream/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/dream/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/dream/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/dream/prebuilt/common/bin/sysinit:system/bin/sysinit

ifneq ($(TARGET_BUILD_VARIANT),user)
# userinit support
PRODUCT_COPY_FILES += \
    vendor/dream/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
endif

# DreamOS-specific init file
PRODUCT_COPY_FILES += \
    vendor/dream/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/dream/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/dream/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is DreamOS!
PRODUCT_COPY_FILES += \
    vendor/dream/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# T-Mobile theme engine
include vendor/dream/config/themes_common.mk

# Required packages
PRODUCT_PACKAGES += \
    Development \
    BluetoothExt \
    Profiles

# Optional CM packages
PRODUCT_PACKAGES += \
    Basic \
    libemoji \
    Terminal

# CM Platform Library
PRODUCT_PACKAGES += \
    org.cyanogenmod.platform-res \
    org.cyanogenmod.platform \
    org.cyanogenmod.platform.xml

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in CM
PRODUCT_PACKAGES += \
    libsepol \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# Custom packages
    Launcher3 \
    Trebuchet \
    AudioFX \
    LockClock \

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libstagefright_soft_ffmpegadec \
    libstagefright_soft_ffmpegvdec \
    libFFmpegExtractor \
    libnamparser

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    procmem \
    procrank \
    su
endif

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

PRODUCT_PACKAGE_OVERLAYS += vendor/dream/overlay/common

PRODUCT_VERSION_MAJOR = 1
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE = 0-RC0

ifndef DREAM_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "DREAM_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^CM_||g')
        DREAM_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter weekly nightly release experimental,$(DREAM_BUILDTYPE)),)
    DREAM_BUILDTYPE :=
endif

ifdef DREAM_BUILDTYPE
    ifneq ($(DREAM_BUILDTYPE), release)
        ifdef DREAM_EXTRAVERSION
            # Force build type to experimental
            DREAM_BUILDTYPE := experimental
            # Remove leading dash from DREAM_EXTRAVERSION
            CM_EXTRAVERSION := $(shell echo $(DREAM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to DREAM_EXTRAVERSION
            DREAM_EXTRAVERSION := -$(DREAM_EXTRAVERSION)
        endif
    else
        ifndef DREAM_EXTRAVERSION
            # Force build type to experimental, release mandates a tag
            DREAM_BUILDTYPE := experimental
        else
            # Remove leading dash from DREAM_EXTRAVERSION
            DREAM_EXTRAVERSION := $(shell echo $(DREAM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to DREAM_EXTRAVERSION
            DREAM_EXTRAVERSION := -$(DREAMM_EXTRAVERSION)
        endif
    endif
else
    # If DREAM_BUILDTYPE is not defined, set to unofficial
    DREAM_BUILDTYPE := unofficial
    DREAM_EXTRAVERSION :=
endif

ifeq ($(DREAM_BUILDTYPE), unofficial)
    ifneq ($(TARGET_unofficial_BUILD_ID),)
        DREAM_EXTRAVERSION := -$(TARGET_unofficial_BUILD_ID)
    endif
endif

ifeq ($(DREAM_BUILDTYPE), release)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        DREAM_VERSION := dreamos_$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(DREAM_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            DREAM_VERSION := dreamos_(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(DREAM_BUILD)
        else
            DREAM_VERSION := dreamoos_(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(DREAM_BUILD)
        endif
    endif
else
    ifeq ($(PRODUCT_VERSION_MINOR),0)
        DREAM_VERSION := dreamos_(PRODUCT_VERSION_MAJOR)-$(shell date -u +%Y%m%d)-$(DREAM_BUILDTYPE)$(DREAM_EXTRAVERSION)-$(DREAM_BUILD)
    else
        DREAM_VERSION := dreamos_(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(DREAM_BUILDTYPE)$(DREAM_EXTRAVERSION)-$(DREAM_BUILD)
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.dream.version=$(DREAM_VERSION) \
  ro.dream.releasetype=$(DREAM_BUILDTYPE) \
  ro.modversion=$(DREAM_VERSION) \

-include vendor/dream-priv/keys/keys.mk

DREAM_DISPLAY_VERSION := $(DREAM_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(DREAM_BUILDTYPE), official)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
      ifneq ($(DREAM_EXTRAVERSION),)
        # Remove leading dash from CM_EXTRAVERSION
        DREAM_EXTRAVERSION := $(shell echo $(DREAM_EXTRAVERSION) | sed 's/-//')
        TARGET_VENDOR_RELEASE_BUILD_ID := $(DREAM_EXTRAVERSION)
      else
        TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
      endif
    else
      TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
    endif
    DREAM_DISPLAY_VERSION=dreamos_(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)
  endif
endif
endif

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

PRODUCT_PROPERTY_OVERRIDES += \
  ro.dream.display.version=$(DREAM_DISPLAY_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
