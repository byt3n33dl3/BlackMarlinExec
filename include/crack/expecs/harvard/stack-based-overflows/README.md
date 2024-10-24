* Let’s use a few lines of simple code to demonstrate the behaviour :
    ```
    #include  

    void do_something(char *Buffer)
    {
        char MyVar[128];
        strcpy(MyVar,Buffer);
    }

    int main (int argc, char **argv)
    {
        do_something(argv[1]);
    }
    ```
* The disassembly of the function looks like this :
    ```
    00401290  /$ 55             PUSH EBP
    00401291  |. 89E5           MOV EBP,ESP
    00401293  |. 81EC 98000000  SUB ESP,98
    00401299  |. 8B45 08        MOV EAX,DWORD PTR SS:[EBP+8]             ; |
    0040129C  |. 894424 04      MOV DWORD PTR SS:[ESP+4],EAX             ; |
    004012A0  |. 8D85 78FFFFFF  LEA EAX,DWORD PTR SS:[EBP-88]            ; |
    004012A6  |. 890424         MOV DWORD PTR SS:[ESP],EAX               ; |
    004012A9  |. E8 72050000    CALL                 ; \strcpy
    004012AE  |. C9             LEAVE
    004012AF  \. C3             RETN
    ```
    <p align="center"><img src="https://i.imgur.com/RxhgDYv.png"  width="400px" height="auto"></p>
* The epilog instruction is executed by a __LEAVE__ instruction (which will restore both the frame pointer and EIP).
* So… Suppose you can overwrite the buffer in MyVar, EBP, EIP and you have A’s (your own code) in the area before and after saved EIP… think about it. After sending the buffer __([MyVar][EBP][EIP][your code])__, ESP will/should point at the beginning of [your code]. So if you can make EIP go to your code, you’re in control.
* When a buffer on the stack overflows, the term _stack based overflow_ or _stack buffer overflow_ is used. When you are trying to write past the end of the stack frame, the term _stack overflow_ is used. Don’t mix those two up, as they are entirely different.
* The next step is to determining the buffer size to write exactly into EIP. Metasploit has a nice tool to assist us with calculating the offset.
	- ./pattern_create.rb -l 5000 
	- ./pattern_offset.rb -q 0x356b4234 -l 5000
* We control EIP. So we can point EIP to somewhere else, to a place that contains our own code (shellcode). But where is this space, how can we put our shellcode in that location and how can we make EIP jump to that location ?
* When the application crashes, take a look at the registers and dump all of them (d esp, d eax, d ebx, d ebp, …). If you can see your buffer (either the A’s or the C’s) in one of the registers, then you may be able to replace those with shellcode and jump to that location.
* Jumping directly to a memory address may not be a good solution after all. (0x000ff730 contains a __null byte__, which is a string terminator… so the A’s you are seeing are coming from the first part of the buffer… We never reached the point where we started writing our data after overwrite EIP.
* Besides, using a memory address to jump to in an exploit would make the exploit very unreliable. After all, this memory address could be different in other OS versions, languages, etc…)
* Search for `jmp esp` VA in loaded DLLs": s <LOADED_DLL_VA_START> l <LOADED_DLL_VA_END> <opcodes> (`s 70000000 l fffffff ff e4`)
* If we can find the opcode in one of Easy RM to MP3 dll’s, then we have a good chance of making the exploit work reliably across windows platforms. If we need to use a dll that belongs to the OS, then we might find that the exploit does not work for other versions of the OS.
* If the address starts with a null byte, because of little endian, the null byte would be the last byte in the EIP register. And if you are not sending any payload after overwrite EIP (so if the shellcode is fed before overwriting EIP, and it is still reachable via a register), then this will work.
* If you have a size limitation in terms of buffer space, then you might even want to look at __multi-staged shellcode__, or using specifically handcrafted shellcodes such as this one [32byte cmd.exe shellcode for xp sp2 en](https://packetstormsecurity.com/shellcode/23bytes-shellcode.txt).
* Alternatively, you can split up your shellcode in smaller ‘eggs’ and use a technique called __egg-hunting__ to reassemble the shellcode before executing it.
* Longer shellcode increases the risk on invalid characters in the shellcode, which need to be filtered out.
* The m3u file probably should contain filenames. So a good start would be to filter out all characters that are not allowed in filenames and filepaths. You could also restrict the character set altogether by using another decoder. We have used __shikata_ga_nai__, but perhaps __alpha_upper__ will work better for filenames.
* There are multiple methods of forcing the execution of shellcode.
	- __JMP or CALL reg__: use this technique if you have your shellcode directly pointed by any if the reg.
	- __POP + RET__ is only usabled when ESP+offset already contains an address which points to the shellcode.
    - __PUSH + RET__: is somewhat similar to call [reg]. If one of the registers is directly pointing at your shellcode, and if for some reason you cannot use a jmp [reg] to jump to the shellcode.
	- JMP [reg + offset] : Another technique to overcome the problem that the shellcode begins at an offset of a register (ESP in our example) is by trying to find a jmp [reg + offset] instruction (and overwriting EIP with the address of that instruction)
	- __Blind return__: 
		- Overwrite EIP with an address pointing to a ret instruction
		- Hardcode the address of the shellcode at the first 4 bytes of ESP.
        - ```[26094 A’s][address of ret][0x000fff730][shellcode]```
        - The problem with this example is that the address used to overwrite EIP contains a null byte.
* Dealing with small buffers:
	- Jumping anywhere with custom jumpcode.
	- Some other ways to jump:
		- __popad__: will thus take 32 bytes from ESP and pops them in the registers in an orderly fashion.
		- hardcode address to jump to
* Extra notes:
* Just remember that a typical stack based overflow, where you overwrite EIP, could potentionally be subject to a SEH based exploit technique as well, giving you more stability, a larger buffer size (and overwriting EIP would trigger SEH… so it’s a win win
Once you jump to your shellcode, you often need to know what address EIP actually is. The stack is usually not at the same position. Here’s the easiest way to do it:
    ```
    call getip
    getip:
    pop eax ; eax now contains eip
    ```
* The problem is that the above code compiles to E8 00 00 00 00 58, which is useless if you can’t have null bytes. My solution is the following:
    ```
    xor eax, eax
    getip:
    cmp eax, -1
    je popip
    mov eax, -1
    call getip
    popip:
    pop eax
    ```
* The above compiles to: 33 C0 83 F8 FF 74 0A B8 FF FF FF FF E8 F1 FF FF FF 58. It’s longer, but no nulls! You can then xor any null bytes in your code with FFFFFFFF and use xor dword ptr [eax + ], FFFFFFFF to patch them back at runtime.