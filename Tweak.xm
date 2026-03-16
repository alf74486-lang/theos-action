#include <substrate.h>
#include <mach-o/dyld.h>
#include <iostream>
#include <vector>
#include <string>
#include "imgui.h"
#include "imgui_impl_metal.h"
#include "easywsclient.hpp"
#include "imgui_impl_ios.h"
#import <Metal/Metal.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
using easywsclient::WebSocket;
static WebSocket::pointer ws = nullptr; 
// متغيرات التحكم بالبوتات
bool show_menu = true;
char server_ip[128] = "ws://127.0.0.1:8080";
int bot_count = 0;
char bot_name[32] = "GeminiBot";
bool is_connected = false;

void SendCommandToServer(std::string command) {

  if (!ws || !ws->is_open()) {
    ws = WebSocket::from_url(server_ip);
}

if (ws && ws->is_open()) {
    std::string jsonCommand = "{\"command\": \"" + command + "\"}";
    ws->send(jsonCommand);
    ws->poll();
}
}


// رسم القائمة باستخدام ImGui
void DrawMenu() {
    if (!show_menu) return;

    ImGui::Begin("Agar.io Bot Controller v1.0", &show_menu);

    ImGui::Text("إعدادات الاتصال");
    ImGui::InputText("سيرفر البوتات", server_ip, IM_ARRAYSIZE(server_ip));
    
    if (ImGui::Button("اتصال بالسيرفر")) {
        // منطق الاتصال
        is_connected = true;
    }

    ImGui::Separator();

    if (is_connected) {
        ImGui::Text("إحصائيات: %d بوت نشط", bot_count);
        ImGui::InputText("اسم البوتات", bot_name, IM_ARRAYSIZE(bot_name));

        ImGui::Spacing();
        ImGui::Text("أوامر التحكم:");

        if (ImGui::Button("تفييد (Feed Me)")) {
            SendCommandToServer("FEED");
        }
        ImGui::SameLine();
        if (ImGui::Button("انقسام (Split)")) {
            SendCommandToServer("SPLIT");
        }
        
        if (ImGui::Button("توزيع (Scatter)")) {
            SendCommandToServer("SCATTER");
        }

        ImGui::SliderInt("عدد البوتات", &bot_count, 0, 1000);
    } else {
        ImGui::TextColored(ImVec4(1,0,0,1), "الرجاء الاتصال بالسيرفر أولاً");
    }

    ImGui::End();
}
id<MTLRenderCommandEncoder> renderEncoder; // المحرك الذي سيرسم
UIView* view; // الشاشة التي ستستقبل اللمس
void (*old_Update)(void* instance);
void new_Update(void* instance) {
       old_Update(instance); 

if (renderEncoder && view) {
    // 1. نحتاج الحصول على الـ View والـ RenderEncoder (يتم جلبهم من محرك اللعبة)
    // بفرض أننا حصلنا عليهم:
    ImGui_ImplMetal_NewFrame(renderEncoder); 
    ImGui_ImplIOS_NewFrame(view);
    ImGui::NewFrame();

    DrawMenu(); // استدعاء واجهتك

    ImGui::Render();
    ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), renderEncoder);
}
}
// نقطة الانطلاق عند تحميل الـ dylib
__attribute__((constructor))
static void initialize() {
    // استبدال دالة التحديث في محرك اللعبة (Unity/Cocos2d)
    // العناوين تختلف حسب إصدار اللعبة
    MSHookFunction((void*)0x100XXXXXX, (void*)&new_Update, (void**)&old_Update);
}
