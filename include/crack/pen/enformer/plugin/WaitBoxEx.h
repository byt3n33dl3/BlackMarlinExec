
// WaitBoxEx: Custom IDA Pro wait box
// By Sirmabus
// Version 1.1
// http://www.macromonkey.com
// License: Qt 4.8.4 LGPL
#pragma once

#ifndef _LIB
#ifndef _DEBUG
#pragma comment(lib, "WaitBoxEx.LiB")
#else
#pragma comment(lib, "WaitBoxExD.LiB")
#endif
#endif

namespace WaitBox
{
    // Show the modal wait box dialog
    void _cdecl show(LPCSTR titleText = "Progress", LPCSTR labelText = "Please wait..", LPCSTR styleSheet = NULL, LPCSTR icon = NULL);

    // Stop the wait box
    void _cdecl hide();

    // Check if user canceled and optionally the update progress too w/built-in timed update limiter.
    // Progress range: 0 to 100, or -1 to switch to indeterminate mode.
    BOOL _cdecl updateAndCancelCheck(int progress = 0);


    // Returns TRUE if ready for internal update
    BOOL _cdecl isUpdateTime();

    // Returns TRUE if wait box up
    BOOL _cdecl isShowing();

    // Change the label text
    void _cdecl setLabelText(LPCSTR labelText);

    // Convenience wrapper of Qt function "QApplication::processEvents();" to tick IDA's Qt event queue
    void _cdecl processIdaEvents();
};


