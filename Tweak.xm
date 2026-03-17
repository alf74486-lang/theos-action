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

// الخطأ الأول: يجب تعريف old_Update قبل استخدامه في دالة new_Update
void (*old_Update)(void* instance);

// الرابط الأساسي اللي عرفته أنت فوق
WebSocket::pointer ws = WebSocket::from_url("wss://web-production-8ade7.up.railway.app");

// --- متغيرات التحكم بالبوتات ---
bool show_menu = true;
char server_ip[128] = "ws://127.0.0.1:8080"; // آي بي اللابتوب حقك
int bot_count = 0;
char bot_name[32] = "GeminiBot";
char party_key_input[32] = ""; // مكان تخزين رمز الغرفة (FNHRAY مثلاً)
bool is_connected = false;

// --- دالة إرسال البيانات للسيرفر المحدثة ---
void SendCommandToServer(std::string jsonPayload) {
    // إذا كان الرابط المكتوب في المنيو مختلف عن الرابط الحالي، أغلق القديم وافتح الجديد
    static std::string current_connected_ip = "";
    
    if (std::string(server_ip) != current_connected_ip) {
        if (ws) {
            ws->close();
            ws = NULL;
        }
        current_connected_ip = std::string(server_ip);
        ws = WebSocket::from_url(current_connected_ip);
        printf("🔄 جاري التحويل إلى سيرفر جديد: %s\n", server_ip);
    }

    // التأكد من أن الاتصال قائم قبل الإرسال
    if (!ws || ws->getReadyState() == WebSocket::CLOSED) {
        ws = WebSocket::from_url(server_ip);
    }

    if (ws && ws->getReadyState() != WebSocket::CLOSED) {
        ws->send(jsonPayload);
        ws->poll(); // مهم جداً لمعالجة الإرسال
    }
}

// --- رسم القائمة باستخدام ImGui ---
void DrawMenu() {
    if (!show_menu) return;

    ImGui::Begin("Agar.io Bot Controller v1.0", &show_menu);

    ImGui::Text("إعدادات الاتصال");
    ImGui::InputText("سيرفر البوتات", server_ip, IM_ARRAYSIZE(server_ip));
    ImGui::InputText("رمز الغرفة (Party)", party_key_input, IM_ARRAYSIZE(party_key_input));

    if (ImGui::Button("اتصال وتشغيل البوتات")) {
        is_connected = true;
        
        // بكرة بنحط الرابط الحقيقي هنا بعد ما نصيده بـ Frida
        std::string game_url = "wss://REPLACE_WITH_REAL_URL"; 

        // تجميع البيانات في رسالة JSON واحدة للسيرفر
        std::string startCmd = "{\"command\": \"START_BOTS\", \"bot_count\": " + std::to_string(bot_count) + 
                               ", \"server_url\": \"" + game_url + 
                               "\", \"party_key\": \"" + std::string(party_key_input) + "\"}";
        
        SendCommandToServer(startCmd);
    }

    ImGui::Separator();

    if (is_connected) {
        ImGui::Text("إحصائيات: %d بوت نشط", bot_count);
        ImGui::InputText("اسم البوتات", bot_name, IM_ARRAYSIZE(bot_name));

        ImGui::Spacing();
        ImGui::Text("أوامر التحكم السريع:");

        if (ImGui::Button("تفييد (Feed Me)")) {
            SendCommandToServer("{\"command\": \"FEED\"}");
        }
        ImGui::SameLine();
        if (ImGui::Button("انقسام (Split)")) {
            SendCommandToServer("{\"command\": \"SPLIT\"}");
        }
        
        if (ImGui::Button("توزيع (Scatter)")) {
            SendCommandToServer("{\"command\": \"SCATTER\"}");
        }

        ImGui::SliderInt("عدد البوتات", &bot_count, 0, 1000);
    } else {
        ImGui::TextColored(ImVec4(1,0,0,1), "الرجاء الاتصال بالسيرفر أولاً");
    }

    ImGui::End();
}

// --- ربط القائمة بمحرك الرسم (Metal) ---
id<MTLRenderCommandEncoder> renderEncoder; 
UIView* view; 

void new_Update(void* instance) {
    // الخطأ الثاني: يجب أن يكون poll داخل الدالة ليعمل مع كل إطار
    if (ws) ws->poll(); 

    old_Update(instance); 

    if (renderEncoder && view) {
        ImGui_ImplMetal_NewFrame(renderEncoder); 
        ImGui_ImplIOS_NewFrame(view);
        ImGui::NewFrame();

        DrawMenu(); 

        ImGui::Render();
        ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), renderEncoder);
    }
}

// --- نقطة انطلاق الـ dylib عند تشغيل اللعبة ---
__attribute__((constructor))
static void initialize() {
    // بكرة بنطلع الـ Offset الحقيقي بدل الـ XXXXXX
    MSHookFunction((void*)0x100XXXXXX, (void*)&new_Update, (void**)&old_Update);
}
