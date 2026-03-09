ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DeltaMaster

DeltaMaster_FILES = Tweak.xmm
DeltaMaster_CFLAGS = -fobjc-arc
DeltaMaster_CCFLAGS = -std=c++11

include $(THEOS_MAKE_PATH)/tweak.mk
