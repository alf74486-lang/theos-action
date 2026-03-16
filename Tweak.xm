#include <substrate.h>
#include <iostream>
#include <vector>
#include <string>
#include "imgui.h"

// متغيرات التحكم بالبوتات
bool show_menu = true;
char server_ip[128] = "ws://127.0.0.1:8080";
int bot_count = 0;
char bot_name[32] = "GeminiBot";
bool is_connected = false;

// وظائف التحكم (تُرسل كأوامر لسيرفر البوتات)
void SendCommandToServer(std::string command) {
    if (is_connected) {
        // هنا يتم وضع منطق إرسال الأوامر عبر WebSocket
        // مثال: "FEED", "SPLIT", "SCATTER"
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

// Hooking (حقن الكود داخل اللعبة)
void (*old_Update)(void* instance);
void new_Update(void* instance) {
    // استدعاء الوظيفة الأصلية لتجنب الكراش
    old_Update(instance);
    
    // هنا يتم استدعاء رسم القائمة في كل Frame
    DrawMenu();
}

// نقطة الانطلاق عند تحميل الـ dylib
__attribute__((constructor))
static void initialize() {
    // استبدال دالة التحديث في محرك اللعبة (Unity/Cocos2d)
    // العناوين تختلف حسب إصدار اللعبة
    MSHookFunction((void*)0x100XXXXXX, (void*)&new_Update, (void**)&old_Update);
}
