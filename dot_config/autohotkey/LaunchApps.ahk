#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir) ; Ensures a consistent starting directory.
; #Warn  ; Enable warnings to assist with detecting common errors.

DetectHiddenWindows true

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
^p:: Send "^l" ; Go to address bar
^k:: Send "^l"
!o:: Send "^+{Tab}" ; Go to left tab
!u:: Send "^{Tab}" ; Go to right tab
!PgDn:: Send "^+{Tab}" ; Go to left tab
!PgUp:: Send "^{Tab}" ; Go to right tab
!w:: Send "^w" ; Close tab
!t:: Send "^t" ; New tab
#HotIf

; Zen Browser
#HotIf WinActive("ahk_exe zen.exe")
^p:: Send "^k" ; Command palette
!o:: Send "^{Tab}" ; Go to below tab
!u:: Send "^+{Tab}" ; Go to above tab
!PgDn:: Send "^+{Tab}" ; Go to left tab
!PgUp:: Send "^{Tab}" ; Go to right tab
!w:: Send "^w" ; Close tab
!t:: Send "^t" ; New tab
#HotIf

; Window + R - [R]esearch/Browser
#HotIf WinExist("ahk_exe zen.exe ahk_class MozillaWindowClass")
#r::
{
    WinActivate
    Sleep 100
    WinActivate
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 3
    Sleep 100 ; To get GlazeWM to stay focused
    WinActivate
}
#HotIf
#r::
{
    Run("Zen") ; If window doesn't exist, run the app
    WinWait("ahk_exe zen.exe")
    WinActivate("ahk_exe zen.exe")
    WinWaitActive("ahk_exe zen.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 3
}

; Window + M - [M]ail
#HotIf WinExist("ahk_exe Spark Desktop.exe")
#m::
{
    DetectHiddenWindows false
    if (WinExist("ahk_exe Spark Desktop.exe")) { ; If non-hidden GUI window exists unfocused, focus it
      WinActivate("ahk_exe Spark Desktop.exe")
      ; Move mouse to the active window
      WinGetPos , , &width, &height, "A"
      MouseMove width / 3, height / 3
      Sleep 100 ; To get GlazeWM to stay focused
      WinActivate("ahk_exe Spark Desktop.exe")
    } else { ; Already running in the background, so focus it
      Run(A_AppData . "/../Local/Programs/SparkDesktop/Spark Desktop")
    }
    DetectHiddenWindows true
}
#HotIf
#m::
{
    Run(A_AppData . "/../Local/Programs/SparkDesktop/Spark Desktop") ; If window doesn't exist, run the app
    WinWait("ahk_exe Spark Desktop.exe")
    WinActivate("ahk_exe Spark Desktop.exe")
    WinWaitActive("ahk_exe Spark Desktop.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 3, height / 3
}

#HotIf WinExist("ahk_exe olk.exe")
#o::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 3, height / 3
}
#HotIf
#o::
{
    Run("olk.exe") ; If window doesn't exist, run the app
    WinWait("ahk_exe olk.exe")
    WinActivate("ahk_exe olk.exe")
    WinWaitActive("ahk_exe olk.exe")
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 3, height / 3
}

; Window + Z - Notes
#HotIf WinActive('ahk_exe notion.exe')
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
    DetectHiddenWindows false
    if (WinExist("ahk_exe notion.exe")) { ; If non-hidden GUI window exists unfocused, focus it
      WinActivate("ahk_exe notion.exe")
      ; Move mouse to the active window
      WinGetPos , , &width, &height, "A"
      MouseMove width / 3, height / 3
      Sleep 100 ; To get GlazeWM to stay focused
      WinActivate("ahk_exe notion.exe")
    } else { ; Already running in the background, so focus it
      Run(A_Programs . "/Notion")
    }
    DetectHiddenWindows true
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
#HotIf WinExist("ahk_exe notion calendar.exe")
#c::
{
    DetectHiddenWindows false
    if (WinExist("ahk_exe notion calendar.exe")) { ; If non-hidden GUI window exists unfocused, focus it
      WinActivate("ahk_exe notion calendar.exe")
      ; Move mouse to the active window
      WinGetPos , , &width, &height, "A"
      MouseMove width / 3, height / 3
      Sleep 100 ; To get GlazeWM to stay focused
      WinActivate("ahk_exe notion calendar.exe")
    } else { ; Already running in the background, so focus it
      Run(A_Programs . "/Notion Calendar")
    }
    DetectHiddenWindows true
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
#HotIf WinExist("ahk_exe wezterm-gui.exe")
#t::
{
    WinActivate ; If window exists unfocused, focus it
    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
    Sleep 200
    WinActivate ; If window exists unfocused, focus it
}
#HotIf
#t::
{
    ; If window doesn't exist, run the app
    Run("wezterm-gui.exe") ; If window doesn't exist, run the app
    WinWait("ahk_exe wezterm-gui.exe")
    WinActivate("ahk_exe wezterm-gui.exe")
    WinWaitActive("ahk_exe wezterm-gui.exe")

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

    ; Move mouse to the active window
    WinGetPos , , &width, &height, "A"
    MouseMove width / 2, height / 2
}

; Window + V - [V]isual Studio Code
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
#HotIf WinExist("ahk_exe everything.exe")
#s::
{
    DetectHiddenWindows false
    if (WinExist("ahk_exe everything.exe")) { ; If non-hidden GUI window exists unfocused, focus it
      WinActivate("ahk_exe everything.exe")
      ; Move mouse to the active window
      WinGetPos , , &width, &height, "A"
      MouseMove width / 3, height / 3
      Sleep 100 ; To get GlazeWM to stay focused
      WinActivate("ahk_exe everything.exe")
    } else { ; Already running in the background, so focus it
      Run(A_ProgramsCommon . "/Everything")
    }
    DetectHiddenWindows true
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
#HotIf WinExist("ahk_exe Todoist.exe")
#h::
{
    DetectHiddenWindows false
    if (WinExist("ahk_exe Todoist.exe")) { ; If non-hidden GUI window exists unfocused, focus it
      WinActivate("ahk_exe Todoist.exe")
      ; Move mouse to the active window
      WinGetPos , , &width, &height, "A"
      MouseMove width / 3, height / 3
      Sleep 100 ; To get GlazeWM to stay focused
      WinActivate("ahk_exe Todoist.exe")
    } else { ; Already running in the background, so focus it
      Run(EnvGet("LOCALAPPDATA") . "\Programs\todoist\Todoist.exe")
    }
    DetectHiddenWindows true
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

#HotIf WinActive("ahk_exe explorer.exe")
^p:: Send "!d" ; Navigation bar
!p:: Send "!d"
!w:: Send "^w" ; Close
#HotIf

#HotIf WinActive("ahk_exe Slack.exe")
^p:: Send "^k" ; Activate launcher
!p:: Send "^k"
#HotIf

#HotIf WinActive("ahk_exe Bruno.exe")
^p:: Send "^k" ; Search requests
^o:: Send "^{PgUp}" ; Previous tab
!o:: Send "^{PgUp}"
^u:: Send "^{PgDn}" ; Next tab
!u:: Send "^{PgDn}"
+^o:: Send "+^{PgUp}" ; Swap previous tab
+!o:: Send "+^{PgUp}"
+^u:: Send "+^{PgDn}" ; Swap next tab
+!u:: Send "+^{PgDn}"
^n:: Send "^b" ; New request
+^b:: Send "^\" ; Collapse side bar
#HotIf

#HotIf WinActive("ahk_exe Postman.exe")
^p:: Send "^k" ; Search
!p:: Send "^k"
!w:: Send "^w" ; Close request
!u:: Send "^{Tab}" ; Next tab
!o:: Send "+^{Tab}" ; Previous tab
#HotIf

#HotIf WinActive("ahk_exe Ssms.exe")
!u:: Send "!^{PgDn}" ; Window.NextTab
!o:: Send "!^{PgUp}" ; Window.PreviousTab
!w:: Send "^{F4}" ; Window.CloseDocumentWindow
!c:: Send "{F8}" ; View.ObjectExplorer ([C]onnections)
!r:: Send "!^g" ; View.RegisteredServers
!g:: Send "!^g" ; View.RegisteredServers
!i:: Send "{Esc}" ; Window.ActivateDocumentWindow
!s:: Send "!^l" ; View.SolutionExplorer
#HotIf

#HotIf WinActive("ahk_exe gitkraken.exe")
!u:: Send "^{Tab}" ; Next tab
!o:: Send "+^{Tab}" ; Next tab
!w:: Send "^w" ; Close tab
#HotIf

StartFocusSteamGame()
{
    Run("taskkill /F /IM steam.exe", , "Hide") ; Close steam first
    Sleep(2000)
    local randomChoice := Random(1, 4)
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
    } else if (randomChoice = 3) {
        Run("steam://rungameid/3511030")
        WinWait("ahk_exe MiniCozyRoom.exe")
        WinActivate("ahk_exe MiniCozyRoom.exe")
        WinWaitActive("ahk_exe MiniCozyRoom.exe")
    } else {
        Run("steam://rungameid/2826180")
        WinWait("ahk_exe ChillPulse.exe")
        WinActivate("ahk_exe ChillPulse.exe")
        WinWaitActive("ahk_exe ChillPulse.exe")
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
; To add lock functionality to Soundux/Soundpad with focus ritual
~#^+!Insert:: ; WIN + CTRL + ALT + SHIFT + INSERT
~^+!Insert:: ; CTRL + ALT + SHIFT + INSERT
{
    Sleep 2500
    DllCall("user32.dll\LockWorkStation") ; Lock
}
