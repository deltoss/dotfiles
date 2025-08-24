#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir) ; Ensures a consistent starting directory.
; #Warn  ; Enable warnings to assist with detecting common errors.

^Esc::
!Esc::
{
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 3
}

; Window + Enter (Find something)
#HotIf WinActive("ahk_exe flow.launcher.exe")
#Enter:: Send("{Esc}")
#HotIf WinExist("ahk_exe flow.launcher.exe")
#Enter:: WinActivate
#HotIf
#Enter:: Run(A_Programs . "/Flow Launcher/Flow Launcher")

; Window + F - [F]irefox
#HotIf WinActive("ahk_exe firefox.exe")
#f:: WinMinimize ; If window exists and is focused, minimize it
!o:: Send "^+{Tab}" ; Go to left tab
!u:: Send "^{Tab}" ; Go to right tab
!PgDn:: Send "^+{Tab}" ; Go to left tab
!PgUp:: Send "^{Tab}" ; Go to right tab
!w:: Send "^w" ; Close tab
!t:: Send "^t" ; New tab
#HotIf WinExist("ahk_exe firefox.exe")
#f::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 3
}
#HotIf
#f::
{
    Run("Firefox") ; If window doesn't exist, run the app
    WinWait("ahk_exe firefox.exe")
    WinActivate("ahk_exe firefox.exe")
    WinWaitActive("ahk_exe firefox.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 3
}

; Window + B - [B]rowser
#HotIf WinActive('ahk_exe firefox.exe')
#b:: WinMinimize ; If window exists and is focused, minimize it
#HotIf WinExist("ahk_exe firefox.exe")
#b::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 3
}
#HotIf
#b::
{
    Run("Firefox") ; If window doesn't exist, run the app
    WinWait("ahk_exe firefox.exe")
    WinActivate("ahk_exe firefox.exe")
    WinWaitActive("ahk_exe firefox.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 3
}

; Window + M - [M]ail
#HotIf WinActive('ahk_exe thunderbird.exe')
#m:: WinMinimize ; If window exists and is focused, minimize it
#HotIf WinExist("ahk_exe thunderbird.exe")
#m::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 3, height / 3
}
#HotIf
#m::
{
    Run("Thunderbird") ; If window doesn't exist, run the app
    WinWait("ahk_exe thunderbird.exe")
    WinActivate("ahk_exe thunderbird.exe")
    WinWaitActive("ahk_exe thunderbird.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 3, height / 3
}

; Window + Z - Notes
#HotIf WinActive('ahk_exe notion.exe')
#z:: WinMinimize ; If window exists and is focused, minimize it
!o:: Send "^+{Tab}" ; Go to left tab
!u:: Send "^{Tab}" ; Go to right tab
!PgDn:: Send "^+{Tab}" ; Go to left tab
!PgUp:: Send "^{Tab}" ; Go to right tab
^u:: Send "{PgUp}"
^e:: Send "{PgDn}"
!p:: Send "^p" ; Activate launcher
!t:: Send "^t" ; New tab
!w:: Send "^w" ; Close tab
!Left:: Send "^[" ; Go back a page
!Right:: Send "^]" ; Go forward a page
#HotIf WinExist("ahk_exe notion.exe")
#z::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}
#HotIf
#z::
{
    Run(A_Programs . "/Notion") ; If window doesn't exist, run the app
    WinWait("ahk_exe notion.exe")
    WinActivate("ahk_exe notion.exe")
    WinWaitActive("ahk_exe notion.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}

; Window + C - [C]alendar
#HotIf WinActive("ahk_exe notion calendar.exe")
#c:: WinMinimize ; If window exists and is focused, minimize it
#HotIf WinExist("ahk_exe notion calendar.exe")
#c::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}
#HotIf
#c::
{
    Run(A_Programs . "/Notion Calendar") ; If window doesn't exist, run the app
    WinWait("ahk_exe notion calendar.exe")
    WinActivate("ahk_exe notion calendar.exe")
    WinWaitActive("ahk_exe notion calendar.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}

; Window + T - [T]erminal
#HotIf WinActive("ahk_exe wezterm-gui.exe")
#t:: WinMinimize ; If window exists and is focused, minimize it
#HotIf WinExist("ahk_exe wezterm-gui.exe")
#t::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}
#HotIf
#t::
{
    ; If window doesn't exist, run the app
    Run("wezterm-gui.exe") ; If window doesn't exist, run the app
    WinWait("ahk_exe wezterm-gui.exe")
    WinActivate("ahk_exe wezterm-gui.exe")
    WinWaitActive("ahk_exe wezterm-gui.exe")

    ; Uncomment if not using a tiling window manager
    ; Sleep(250)
    ; WinMaximize

    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}

; Window + E - File [E]xplorer
#e::
{
    Run("wezterm-gui.exe start --always-new-process --no-auto-connect -- pwsh -NoExit -c y ~/Downloads/")
    WinWait("ahk_exe wezterm-gui.exe")
    WinActivate("ahk_exe wezterm-gui.exe")
    WinWaitActive("ahk_exe wezterm-gui.exe")

    ; Uncomment if not using a tiling window manager
    ; Sleep(250)
    ; WinMaximize

    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}

; Window + V - [V]isual Studio Code
#HotIf WinActive("ahk_exe code.exe")
#v:: WinMinimize ; If window exists and is focused, minimize it
#HotIf WinExist("ahk_exe code.exe")
#v::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}
#HotIf
#v::
{
    Run(A_Programs . "/Visual Studio Code/Visual Studio Code") ; If window doesn't exist, run the app
    WinWait("ahk_exe code.exe")
    WinActivate("ahk_exe code.exe")
    WinWaitActive("ahk_exe code.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}

; Window + Alt + V - [V]isual Studio
#HotIf WinActive("ahk_exe devenv.exe")
#!v:: WinMinimize ; If window exists and is focused, minimize it
#HotIf WinExist("ahk_exe devenv.exe")
#!v::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}
#HotIf
#!v::
{
    Run("devenv") ; If window doesn't exist, run the app
    WinWait("ahk_exe devenv.exe")
    WinActivate("ahk_exe devenv.exe")
    WinWaitActive("ahk_exe devenv.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}

; Window + S (Search)
#HotIf WinActive("ahk_exe everything.exe")
#s:: WinMinimize ; If window exists and is focused, minimize it
#HotIf WinExist("ahk_exe everything.exe")
#s::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 3
}
#HotIf
#s::
{
    Run(A_ProgramsCommon . "/Everything") ; If window doesn't exist, run the app
    WinWait("ahk_exe everything.exe")
    WinActivate("ahk_exe everything.exe")
    WinWaitActive("ahk_exe everything.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}

; Window + W - [W]ord Docs
#HotIf WinActive("ahk_exe editors.exe")
#w:: WinMinimize ; If window exists and is focused, minimize it
#HotIf WinExist("ahk_exe editors.exe")
#w::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}
#HotIf
#w::
{
    Run(A_ProgramsCommon . "/ONLYOFFICE/ONLYOFFICE") ; If window doesn't exist, run the app
    WinWait("ahk_exe editors.exe")
    WinActivate("ahk_exe editors.exe")
    WinWaitActive("ahk_exe editors.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}

; Window + H - [H]abits/ToDo
#HotIf WinActive('ahk_exe Todoist.exe')
#h:: WinMinimize ; If window exists and is focused, minimize it
#HotIf WinExist("ahk_exe Todoist.exe")
#h::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 3, height / 3
}
#HotIf
#h::
{
    Run(EnvGet("LOCALAPPDATA") . "\Programs\todoist\Todoist.exe")
    WinWait("ahk_exe Todoist.exe")
    WinActivate("ahk_exe Todoist.exe")
    WinWaitActive("ahk_exe Todoist.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 3, height / 3
}

StartFocusSteamGame()
{
    local randomChoice := Random(1, 3)
    if (randomChoice = 1) {
        Run("steam://rungameid/2113850")
        WinWait("ahk_exe SpiritCity-Win64-Shipping.exe")
        WinActivate("ahk_exe SpiritCity-Win64-Shipping.exe")
        WinWaitActive("ahk_exe SpiritCity-Win64-Shipping.exe")
        Sleep(2000)

        ; Move mouse to the active window
        WinGetPos , , &width, &height, "A"
        MouseMove width / 2, height / 2
    } else if (randomChoice = 2) {
        Run("steam://rungameid/1369320")
        WinWait("ahk_exe Virtual Cottage_WINDOWS.exe")
        WinActivate("ahk_exe Virtual Cottage_WINDOWS.exe")
        WinWaitActive("ahk_exe Virtual Cottage_WINDOWS.exe")
        Send("{F11}")
        Send("{F11}")
        Send("{F11}")
    } else {
        Run("steam://rungameid/3416070")
        WinWait("ahk_exe RopukaIdleIsland.exe")
        WinActivate("ahk_exe RopukaIdleIsland.exe")
        WinWaitActive("ahk_exe RopukaIdleIsland.exe")
    }
}

; Window + Alt + F - [F]ocus Steam Game
#!f::
{
    StartFocusSteamGame()
}

; Window + Alt + Ctrl + F - [F]ocus Tools
#!^f::
{
    Run(A_ProgramsCommon . "/Cold Turkey Software/Cold Turkey Blocker")
    WinWait("ahk_exe Cold Turkey Blocker.exe")

    Run(A_Programs . "/Notion Calendar")

    StartFocusSteamGame()

    MsgBox("🪙 Pay myself first!", "⚡ Coin Reminder ⚡", "Iconi T4")
}

; Lock Windows
; To add lock functionality to Soundpad with focus ritual
~#^+!Insert:: ; WIN + CTRL + ALT + SHIFT + INSERT
~^+!Insert:: ; CTRL + ALT + SHIFT + INSERT
{
    DllCall("user32.dll\LockWorkStation")
}
