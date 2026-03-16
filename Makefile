ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DeltaMaster

# التعديل هنا: أضفنا wildcard لقراءة كل ملفات ImGui والربط تلقائياً
DeltaMaster_FILES = Tweak.xm easywsclient.cpp $(wildcard *.cpp) $(wildcard *.mm)

# إضافة المكتبات اللازمة لظهور الواجهة (بدونها سيحدث كراش)
DeltaMaster_FRAMEWORKS = UIKit Foundation Metal MetalKit QuartzCore

DeltaMaster_CFLAGS = -fobjc-arc -I.
DeltaMaster_CCFLAGS = -std=c++11

include $(THEOS_MAKE_PATH)/tweak.mk
