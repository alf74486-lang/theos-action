TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Agar.io

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DeltaMaster
DeltaMaster_FILES = Tweak.x
DeltaMaster_FRAMEWORKS = UIKit WebKit Foundation
DeltaMaster_LIBRARIES = substrate
DeltaMaster_CFLAGS = -fobjc-arc -std=c++11

include $(THEOS_MAKE_PATH)/tweak.mk
# Trigger Build
