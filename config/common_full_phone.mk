# Inherit common DREAM stuff
$(call inherit-product, vendor/dream/config/common_full.mk)

# Required packages
PRODUCT_PACKAGES += \
    LatinIME

# Include DREAM LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/dream/overlay/dictionaries

# Default notification/alarm sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Argon.ogg \
    ro.config.alarm_alert=Helium.ogg

ifeq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
    PRODUCT_COPY_FILES += \
        vendor/dream/prebuilt/common/bootanimation/480.zip:system/media/bootanimation.zip
endif

$(call inherit-product, vendor/dream/config/telephony.mk)
