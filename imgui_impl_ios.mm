#import "imgui_impl_ios.h"
#import <UIKit/UIKit.h>

// منطق التعامل مع اللمس (Touch Handling)
static UIView* g_View = nil;
static double g_Time = 0.0;

bool ImGui_ImplIOS_Init(UIView* view) {
    g_View = view;
    ImGuiIO& io = ImGui::GetIO();
    io.BackendPlatformName = "imgui_impl_ios";
    return true;
}

void ImGui_ImplIOS_NewFrame(UIView* view) {
    ImGuiIO& io = ImGui::GetIO();
    CGRect rect = view.bounds;
    io.DisplaySize = ImVec2(rect.size.width, rect.size.height);
    
    // حساب الوقت لضمان سلاسة حركة القائمة
    double current_time = CACurrentMediaTime();
    io.DeltaTime = g_Time > 0.0 ? (float)(current_time - g_Time) : (float)(1.0f/60.0f);
    g_Time = current_time;
}

void ImGui_ImplIOS_Shutdown() {
    g_View = nil;
}
