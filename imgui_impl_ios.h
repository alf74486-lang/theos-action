#pragma once
#include "imgui.h"

// هذه الدوال هي اللي تربط اللمس في الأيفون بـ ImGui
IMGUI_IMPL_API bool     ImGui_ImplIOS_Init(UIView* view);
IMGUI_IMPL_API void     ImGui_ImplIOS_Shutdown();
IMGUI_IMPL_API void     ImGui_ImplIOS_NewFrame(UIView* view);
IMGUI_IMPL_API void ImGui_ImplIOS_HandleEvent(UITouch* touch, UIView* view, int eventType);
// eventType: 0=Began, 1=Moved, 2=Ended
