+$(call inherit-product, device/motorola/falcon/full_falcon.mk)
+
+# Inherit some common dream stuff
+$(call inherit-product, vendor/dream/config/common_full_phone.mk)
+
+PRODUCT_RELEASE_NAME := moto g
+PRODUCT_NAME := dream_falcon
