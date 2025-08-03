#Requires AutoHotkey v2.0
#SingleInstance Force

global FIXED_TOOLTIP_X := 357
global FIXED_TOOLTIP_Y := 410
global cycleCount := 0
global autoSellEnabled := false
global autoSellCycles := 100
global showDebugTooltips := false
global mainGui := ""
global tooltipCheckbox := ""
global cycleText := ""
global autoSellCheckbox := ""
global autoSellInput := ""
global settingsFile := "settings.ini"

LoadSettings()
CreateMainGui()

F1::
{
    global cycleCount
    ShowDebugTooltip("starting macro")
    
    ResizeRobloxWindow()
    Sleep 1000
    SafeMoveRelative(0.565, 0.614)

    ShowDebugTooltip("equipping shovel")
    Send "{2}"
    Sleep 200
    Send "{1}"
    Sleep 300

    ShowDebugTooltip("starting digging")
    Loop {
        ShowDebugTooltip("iteration starting")
        
        Click("Down")
        Sleep(100)

        while (GetKeyState("LButton", "P")) {
            detectionX := 575
            startY := 275
            endY := 280

            ShowDebugTooltip("holding click")

            whitePixelFound := false
            Loop (endY - startY + 1) {
                currentY := startY + A_Index - 1
                currentColor := PixelGetColor(detectionX, currentY)
                
                ShowDebugTooltip("checking for click")
                
                if (currentColor = 0xFFFFFF) {
                    whitePixelFound := true
                    break
                }
            }

            if (whitePixelFound) {
                ShowDebugTooltip("releasing click")
                Click("Up")
                
                Sleep(2000)

                checkColor := PixelGetColor(598, 432)
                
                if (checkColor != 0x8C8C8C) {
                    ShowDebugTooltip("digging done moving forward")
                    Send("{w down}")
                    Sleep(600)
                    Send("{w up}")

                    ShowDebugTooltip("pan start click")
                    Click()

                    Sleep(300)

                    ShowDebugTooltip("holding click to pan")
                    Click("Down")
                    Loop {
                        detectedColor := PixelGetColor(359, 432)
                        
                        if (detectedColor = 0x8C8C8C) {
                            ShowDebugTooltip("panning done moving back")
                            Click("Up")

                            Sleep 1800

                            Send("{s down}")
                            Sleep(600)
                            Send("{s up}")
                            Sleep(300)

                            cycleCount++
                            UpdateCycleDisplay()
                            SaveSettings()
                            ShowDebugTooltip("cycle #" . cycleCount . " completed")

                            if (autoSellEnabled && cycleCount >= autoSellCycles) {
                                ShowDebugTooltip("autosell triggered at cycle " . cycleCount)
                                AutoSell()
                                cycleCount := 0
                                UpdateCycleDisplay()
                                SaveSettings()
                                ShowDebugTooltip("autosell completed, cycle count reset")
                            }
                            
                            break
                        }
                        Sleep(1)
                    }
                }

                break
            }

            Sleep(1)
        }
    }
}

F2:: {
    ShowDebugTooltip("reloading")
    SaveSettings
    Sleep(100)
    Reload
}

AutoSell() {
    ShowDebugTooltip("starting autosell sequence")
    Send "g"
    Sleep 200
    ShowDebugTooltip("autoselling")
    SafeMoveRelative(0.350, 0.300)
    Sleep 100
    Click "Left"
    Sleep 50
    SafeMoveRelative(0.355, 0.300)
    Click "Left"
    Sleep 50
    SafeMoveRelative(0.360, 0.300)
    Click "Left"
    Sleep 50
    SafeMoveRelative(0.365, 0.300)
    Click "Left"
    Sleep 50
    SafeMoveRelative(0.370, 0.300)
    Click "Left"
    Sleep 50
    SafeMoveRelative(0.375, 0.300)
    Click "Left"
    Sleep 50
    SafeMoveRelative(0.380, 0.300)
    Click "Left"
    Sleep 500
    Send "g"
    Sleep 500
    ShowDebugTooltip("autosell completed")
}

LoadSettings() {
    global settingsFile, showDebugTooltips, autoSellEnabled, autoSellCycles, cycleCount
    
    try {
        showDebugTooltips := IniRead(settingsFile, "General", "ShowTooltips", false)
        autoSellEnabled := IniRead(settingsFile, "AutoSell", "Enabled", false)
        autoSellCycles := IniRead(settingsFile, "AutoSell", "Cycles", 100)
        cycleCount := IniRead(settingsFile, "General", "CycleCount", 0)

        showDebugTooltips := (showDebugTooltips = "true" || showDebugTooltips = "1")
        autoSellEnabled := (autoSellEnabled = "true" || autoSellEnabled = "1")
        autoSellCycles := Integer(autoSellCycles)
        cycleCount := Integer(cycleCount)

    } catch as e {
    }
}

SaveSettings() {
    global settingsFile, showDebugTooltips, autoSellEnabled, autoSellCycles, cycleCount
    
    try {
        IniWrite(showDebugTooltips ? "true" : "false", settingsFile, "General", "ShowTooltips")
        IniWrite(autoSellEnabled ? "true" : "false", settingsFile, "AutoSell", "Enabled")
        IniWrite(autoSellCycles, settingsFile, "AutoSell", "Cycles")
        IniWrite(cycleCount, settingsFile, "General", "CycleCount")

    } catch as e {
    }
}

CreateMainGui() {
    global mainGui, tooltipCheckbox, cycleText, autoSellCheckbox, autoSellInput
    
    mainGui := Gui("+AlwaysOnTop -MinimizeBox -Resize", "moris prospecting macro v1.0")
    mainGui.BackColor := "F0F0F0"

    mainGui.SetFont("s10 Norm", "Segoe UI")

    mainGui.MarginX := 0
    mainGui.MarginY := 0

    mainGui.Add("GroupBox", "x7 y0 w124 h90 Section", "Autosell")
    autoSellCheckbox := mainGui.Add("Checkbox", "xs+10 ys+25 h25 Checked" . (autoSellEnabled ? "1" : "0"), "Enable Autosell")
    autoSellCheckbox.OnEvent("Click", ToggleAutoSell)
    
    mainGui.Add("Text", "xs+10 ys+55 w80 h23 +0x200", "Sell After:")
    autoSellInput := mainGui.Add("Edit", "xs+75 ys+55 w40 h25 Number Limit3 Center", autoSellCycles)
    autoSellInput.OnEvent("Change", UpdateAutoSellCycles)

    mainGui.Add("GroupBox", "x140 y0 w124 h90 Section", "Other")
    tooltipCheckbox := mainGui.Add("Checkbox", "xs+10 ys+25 h25 Checked" . (showDebugTooltips ? "1" : "0"), "Debug Tooltips")
    tooltipCheckbox.OnEvent("Click", ToggleTooltips)

    mainGui.Add("Text", "xs+10 ys+55 w80 h23 +0x200", "Cycles:")
    cycleText := mainGui.Add("Text", "xs+59 ys+58 w50 h23 +Border +Center +0x200 BackgroundWhite c003366", cycleCount)
    cycleText.SetFont("s11 Bold", "Consolas")

    mainGui.OnEvent("Close", GuiClose)
    mainGui.OnEvent("Escape", GuiClose)

    mainGui.Show("x-7 y630 w272 h97")
    mainGui.Opt("+Border")
}

GuiClose(*) {
    SaveSettings()
    ExitApp()
}

ToggleTooltips(*) {
    global showDebugTooltips, tooltipCheckbox
    showDebugTooltips := tooltipCheckbox.Value
    SaveSettings()
}

ToggleAutoSell(*) {
    global autoSellEnabled, autoSellCheckbox
    autoSellEnabled := autoSellCheckbox.Value
    SaveSettings()
}

UpdateAutoSellCycles(*) {
    global autoSellCycles, autoSellInput
    try {
        newValue := Integer(autoSellInput.Text)
        if (newValue > 0) {
            autoSellCycles := newValue
            SaveSettings()
        }
    } catch {
        autoSellInput.Text := autoSellCycles
    }
}

UpdateTooltipCheckbox() {
    global tooltipCheckbox, showDebugTooltips
    if (tooltipCheckbox) {
        tooltipCheckbox.Value := showDebugTooltips
    }
}

UpdateCycleDisplay() {
    global cycleText, cycleCount
    if (cycleText) {
        cycleText.Text := cycleCount
    }
}

ShowDebugTooltip(message) {
    global showDebugTooltips, FIXED_TOOLTIP_X, FIXED_TOOLTIP_Y
    
    if (!showDebugTooltips) {
        return
    }

    ToolTip()

    ToolTip(message, FIXED_TOOLTIP_X, FIXED_TOOLTIP_Y)

    SetTimer(() => ToolTip(), -2000)
}

ResizeRobloxWindow() {
    global showDebugTooltips, FIXED_TOOLTIP_X, FIXED_TOOLTIP_Y
    
    ShowDebugTooltip("searching for roblox")
    
    robloxWindow := ""
    robloxTitles := ["Roblox", "ahk_exe RobloxPlayerBeta.exe", "ahk_exe RobloxPlayer.exe"]
    
    for title in robloxTitles {
        try {
            if WinExist(title) {
                robloxWindow := title
                ShowDebugTooltip("found roblox: " . title)
                break
            }
        }
    }
    
    if (robloxWindow = "") {
        ShowDebugTooltip("error roblox not found")
        return false
    }
    
    ShowDebugTooltip("opening window: " . robloxWindow)
    try {
        WinActivate(robloxWindow)
        Sleep(100)
        ShowDebugTooltip("window opened")
    } catch as e {
        ShowDebugTooltip("error opening window: " . e.message)
        return false
    }
    try {
        currentStyle := WinGetStyle(robloxWindow)
        ShowDebugTooltip("current window style: 0x" . Format("{:X}", currentStyle))
    } catch as e {
        ShowDebugTooltip("error getting window style: " . e.message)
        return false
    }
    
    if (!(currentStyle & 0x00C00000)) {
        ShowDebugTooltip("exiting fullscreen")
        Send("{F11}")
        Sleep(300)
    }
    
    try {
        WinRestore(robloxWindow)
        WinSetStyle("+0x00C40000", robloxWindow)
        WinMove(-7, 0, 974, 630, robloxWindow)
        ShowDebugTooltip("window resized")
    } catch as e {
        ShowDebugTooltip("error resizing: " . e.message)
        return false
    }

    return true
}

SafeMoveRelative(xRatio, yRatio) {
    robloxTitles := ["ahk_exe RobloxPlayerBeta.exe", "ahk_exe RobloxPlayer.exe", "Roblox"]
    
    for title in robloxTitles {
        if WinExist(title) {
            try {
                WinGetPos(&winX, &winY, &winW, &winH, title)
                moveX := winX + Round(xRatio * winW)
                moveY := winY + Round(yRatio * winH)
                MouseMove(moveX, moveY)
                return
            } catch as e {
            }
        }
    }
}