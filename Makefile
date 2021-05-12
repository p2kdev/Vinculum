TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Vinculum2

Vinculum2_FILES = Tweak.x
Vinculum2_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += vinculum2
include $(THEOS_MAKE_PATH)/aggregate.mk
