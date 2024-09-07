
// IdaOgg: A mini Vorbis Ogg clip player for IDA
// By Sirmabus 2015
// Site: http://www.macromonkey.com
// Using Sean Barrett's "Ogg Vorbis decoder"
// http://nothings.org/stb_vorbis/
#pragma once

#ifndef _LIB
#ifndef _DEBUG
#pragma comment(lib, "IdaOggPlayer.LiB")
#else
#pragma comment(lib, "IdaOggPlayerD.LiB")
#endif
#endif

namespace OggPlay
{
    // Play Ogg from memory source, optionally asynchronously
    void __cdecl playFromMemory(const PVOID memory, int length, BOOL async = FALSE);

    // Stop the currently playing wave if there is one and clean up.
    // This needs to eb called after playOggFromMemory() each time.
    void __cdecl endPlay();
};


