TWEAK_NAME = DeltaMaster
TWEAK_FILES = Tweak.xm

# تضمين ملفات ImGui و WebSocket و Metal و UIKit
DEVELOPER = /Applications/Xcode.app/Contents/Developer
SDKVERSION = 14.0
THEOS = /path/to/theos  # تأكد من ضبط المسار الصحيح لـ Theos هنا

# تحديد الملفات التي سيتم تضمينها
DeltaMaster_FILES = Tweak.xm easywsclient.cpp easywsclient.hpp imgui.cpp imgui_impl_ios.mm imgui_impl_metal.mm imgui_impl_ios.h imgui_impl_metal.h imgui.h

# تضمين مكتبات Metal و UIKit و C++ القياسية
DeltaMaster_FRAMEWORKS = UIKit Foundation Metal QuartzCore

# تمكين C++ لبناء ملف .dylib
CFLAGS = -std=c++11
CPPFLAGS = -std=c++11

# لتمكين بناء ملفات .dylib
LIBRARY_NAME = libDeltaMaster.dylib
OUTPUT_FILE = /tmp/$(LIBRARY_NAME)

# الأوامر الخاصة بالبناء
include $(THEOS)/makefiles/common.mk