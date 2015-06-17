# Inherit common DREAM stuff
$(call inherit-product, vendor/cm/config/common.mk)

# Include CM audio files
include vendor/dream/config/dream_audio.mk

# Required packages
PRODUCT_PACKAGES += \
    LatinIME

# Default notification/alarm sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Argon.ogg \
    ro.config.alarm_alert=Helium.ogg

ifeq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
    PRODUCT_COPY_FILES += \
        vendor/dream/prebuilt/common/bootanimation/800.zip:system/media/bootanimation.zip
endif
