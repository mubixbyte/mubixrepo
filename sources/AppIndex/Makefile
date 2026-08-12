ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:16.0
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppIndex
AppIndex_FILES = main.m AIAppDelegate.m AIAppsViewController.m
AppIndex_FRAMEWORKS = UIKit Foundation
AppIndex_CFLAGS = -fobjc-arc
AppIndex_LDFLAGS = -Wl,-undefined,dynamic_lookup
AppIndex_CODESIGN_FLAGS = -SAppIndex.entitlements
AppIndex_INSTALL_PATH = /Applications

include $(THEOS_MAKE_PATH)/application.mk

before-package::
	chmod 0755 $(THEOS_PROJECT_DIR)/layout/DEBIAN/postinst $(THEOS_PROJECT_DIR)/layout/DEBIAN/prerm
