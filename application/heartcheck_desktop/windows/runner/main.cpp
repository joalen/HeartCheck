#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>
#include <thread> 

#include "flutter_window.h"
#include "winsparkle.h"
#include "utils.h"
#include <iostream>

void initializeUpdateChecker() {
#ifndef _DEBUG
    try {
        if (GetModuleHandle(L"WinSparkle.dll") == NULL) {
            return;  // Silently skip if DLL not found
        }

        const std::string appcastUrl = "https://github.com/joalen/HeartCheck/releases/latest/download/appcast.xml";
        win_sparkle_set_appcast_url(appcastUrl.c_str());
        win_sparkle_init();
    } catch (...) {
        // Silently catch all exceptions to prevent app crash
    }
#endif
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"HeartCheck", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);
  initializeUpdateChecker();

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  #ifndef _DEBUG
    win_sparkle_cleanup();
  #endif
    ::CoUninitialize();
    return EXIT_SUCCESS;
}
