#import "imgui_impl_ios.h"
#import <UIKit/UIKit.h>

// متغيرات التحكم الداخلية
static UIView* g_View = nil;
static double g_Time = 0.0;

// تشغيل الواجهة وربطها بالـ View
bool ImGui_ImplIOS_Init(UIView* view) {
    g_View = view;
    ImGuiIO& io = ImGui::GetIO();
    io.BackendPlatformName = "imgui_impl_ios";
    
    // إعدادات اختيارية لتحسين تجربة اللمس على iOS
    io.ConfigFlags |= ImGuiConfigFlags_IsTouchScreen; 
    
    return true;
}

// تحديث الإطار (Frame) وحساب الوقت وحجم الشاشة
void ImGui_ImplIOS_NewFrame(UIView* view) {
    ImGuiIO& io = ImGui::GetIO();
    
    // تحديث حجم الشاشة بناءً على الـ View الحالي
    CGRect rect = view.bounds;
    float scale = [UIScreen mainScreen].scale;
    io.DisplaySize = ImVec2(rect.size.width, rect.size.height);
    io.DisplayFramebufferScale = ImVec2(scale, scale);
    
    // حساب DeltaTime لضمان سلاسة الحركة والانيميشن
    double current_time = CACurrentMediaTime();
    io.DeltaTime = g_Time > 0.0 ? (float)(current_time - g_Time) : (float)(1.0f/60.0f);
    g_Time = current_time;
}

// تنظيف الذاكرة عند الإغلاق
void ImGui_ImplIOS_Shutdown() {
    g_View = nil;
    g_Time = 0.0;
}

// الدالة السحرية: معالجة اللمس لجعل القائمة تتحرك وتستجيب
void ImGui_ImplIOS_HandleEvent(UITouch* touch, UIView* view, int eventType) {
    ImGuiIO& io = ImGui::GetIO();
    
    // تحويل إحداثيات اللمس من الشاشة إلى داخل الـ View
    CGPoint location = [touch locationInView:view];
    io.MousePos = ImVec2(location.x, location.y);

    switch (eventType) {
        case 0: // Began (بداية اللمس)
            io.MouseDown[0] = true;
            break;
        case 1: // Moved (تحريك الإصبع)
            // الاحداثيات تتحدث تلقائياً فوق عبر io.MousePos
            break;
        case 2: // Ended (رفع الإصبع)
        case 3: // Cancelled (إلغاء اللمس كوصول اتصال مثلاً)
            io.MouseDown[0] = false;
            break;
    }
}
