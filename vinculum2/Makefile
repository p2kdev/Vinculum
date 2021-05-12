ARCHS = arm64 arm64e
TARGET := iphone:13.0:13.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Vinculum2

Vinculum2_FILES = WVRootListController.m
Vinculum2_FRAMEWORKS = UIKit
Vinculum2_PRIVATE_FRAMEWORKS = Preferences
Vinculum2_INSTALL_PATH = /Library/PreferenceBundles
Vinculum2_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk