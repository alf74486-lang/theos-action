#pragma once
#include "imgui.h"

// هذه الدوال هي اللي تربط اللمس في الأيفون بـ ImGui
IMGUI_IMPL_API bool     ImGui_ImplIOS_Init(UIView* view);
IMGUI_IMPL_API void     ImGui_ImplIOS_Shutdown();
IMGUI_IMPL_API void     ImGui_ImplIOS_NewFrame(UIView* view);
