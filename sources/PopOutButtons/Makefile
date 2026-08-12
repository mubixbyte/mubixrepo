TARGET := iphone:clang:latest:13.0
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PopOutButtons

PopOutButtons_FILES = $(wildcard *.x *.m *.c )
PopOutButtons_CFLAGS = -fobjc-arc
PopOutButtons_LDFLAGS = -Wl,-undefined,dynamic_lookup

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += popoutbuttonsprefs

include $(THEOS_MAKE_PATH)/aggregate.mk
