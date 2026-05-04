# GeJie Makefile
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard Shopee

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GeJie

GeJie_FILES = Tweak.xm GeJieFloatWindow.m GeJieNetworkManager.m
GeJie_CFLAGS = -fobjc-arc
GeJie_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
GeJie_LDFLAGS = -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk
