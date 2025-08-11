#Requires AutoHotkey v2.0
#SingleInstance Force

global FIXED_TOOLTIP_X := 357
global FIXED_TOOLTIP_Y := 410
global cycleCount := 0
global autoSellEnabled := false
global autoSellCycles := 100
global showDebugTooltips := false
global walkTime := 100
global nextDigWait := 2000
global mainGui := ""
global tooltipCheckbox := ""
global cycleText := ""
global autoSellCheckbox := ""
global autoSellInput := ""
global walkTimeInput := ""
global nextDigWaitInput := ""
global settingsFile := "settings.ini"
global oneTimeDigFull := false
global oneTimeDigFullCheckbox := ""
global detectionX := 575
global startY := 275
global endY := 280
global detectionXInput := ""
global startYInput := ""
global endYInput := ""

LoadSettings()
CreateMainGui()

F1::
{
    global cycleCount, oneTimeDigFull, detectionX, startY, endY
    ShowDebugTooltip("starting macro")
    
    ResizeRobloxWindow()
    Sleep 1000
    SafeMoveRelative(0.565, 0.614)

    ShowDebugTooltip("equipping shovel")
    Send "{2}"
    Sleep 200
    Send "{1}"
    Sleep 300

    Loop {
        ShowDebugTooltip("starting digging")
        Sleep 300
        Click("Down")

        while (GetKeyState("LButton", "P")) {
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
                
                Sleep(nextDigWait)

                checkColor := PixelGetColor(598, 432)
                
                if (checkColor != 0x8C8C8C) {
                    ShowDebugTooltip("digging done moving forward")

                    Send("{w down}")
                    Loop {
                        currentColor := PixelGetColor(453, 498)
                        if (currentColor = 0x353535) {
                            Sleep(walkTime)
                            Send("{w up}")
                            ShowDebugTooltip("forward position reached")
                            Sleep(300)
                            break
                        }
                        Sleep(1)
                    }

                    ShowDebugTooltip("pan start click")

                    Sleep(300)

                    ShowDebugTooltip("panning")
                    Loop {
                        detectedColor := PixelGetColor(359, 432)
                        
                        if (detectedColor = 0x8C8C8C) {
                            ShowDebugTooltip("panning done moving back")
                            
                            Sleep 1800

                            ShowDebugTooltip("moving back")
                            Send("{s down}")
                            Loop {
                                currentColor := PixelGetColor(408, 498)
                                if (currentColor = 0x353535) {
                                    Sleep(walkTime)
                                    Send("{s up}")
                                    ShowDebugTooltip("back position reached")
                                    Sleep(300)
                                    break
                                }
                                Sleep(1)
                            }
                            
                            if (!oneTimeDigFull) {
                                ShowDebugTooltip("starting digging again")
                                Sleep 300
                                Click("Down")

                                Loop {
                                    whitePixelFound := false
                                    Loop (endY - startY + 1) {
                                        currentY := startY + A_Index - 1
                                        currentColor := PixelGetColor(detectionX, currentY)
                                        
                                        if (currentColor = 0xFFFFFF) {
                                            whitePixelFound := true
                                            break
                                        }
                                    }

                                    if (whitePixelFound) {
                                        ShowDebugTooltip("releasing click to dig")
                                        Click("Up")
                                        Sleep(nextDigWait)
                                        break
                                    }
                                    Sleep(1)
                                }
                            }

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
                                ShowDebugTooltip("autosell completed")
                            }
                            
                            break
                        }

                        Click("Left")
                        Sleep(10)
                    }
                }

                break
            }

            Sleep(1)
        }
    }
}

F2:: {
    global cycleCount
    cycleCount := 0
    ShowDebugTooltip("reloading")
    UpdateCycleDisplay()
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
    global settingsFile, showDebugTooltips, autoSellEnabled, autoSellCycles, walkTime, nextDigWait, oneTimeDigFull, startY, endY
    
    try {
        showDebugTooltips := IniRead(settingsFile, "General", "ShowTooltips", false)
        oneTimeDigFull := IniRead(settingsFile, "General", "OneTimeDigFull", false)
        autoSellEnabled := IniRead(settingsFile, "AutoSell", "Enabled", false)
        autoSellCycles := IniRead(settingsFile, "AutoSell", "Cycles", 100)
        walkTime := IniRead(settingsFile, "Variables", "WalkTime", 100)
        nextDigWait := IniRead(settingsFile, "Variables", "NextDigWait", 2000)
        startY := IniRead(settingsFile, "Variables", "StartY", 275)
        endY := IniRead(settingsFile, "Variables", "EndY", 280)

        showDebugTooltips := (showDebugTooltips = "true" || showDebugTooltips = "1")
        oneTimeDigFull := (oneTimeDigFull = "false" || oneTimeDigFull = "0")
        autoSellEnabled := (autoSellEnabled = "true" || autoSellEnabled = "1")
        autoSellCycles := Integer(autoSellCycles)
        walkTime := Integer(walkTime)
        nextDigWait := Integer(nextDigWait)
        startY := Integer(startY)
        endY := Integer(endY)

    } catch as e {
    }
}

SaveSettings() {
    global settingsFile, showDebugTooltips, autoSellEnabled, autoSellCycles, walkTime, nextDigWait, oneTimeDigFull, startY, endY
    
    try {
        IniWrite(showDebugTooltips ? "true" : "false", settingsFile, "General", "ShowTooltips")
        IniWrite(oneTimeDigFull ? "true" : "false", settingsFile, "General", "OneTimeDigFull")
        IniWrite(autoSellEnabled ? "true" : "false", settingsFile, "AutoSell", "Enabled")
        IniWrite(autoSellCycles, settingsFile, "AutoSell", "Cycles")
        IniWrite(walkTime, settingsFile, "Variables", "WalkTime")
        IniWrite(nextDigWait, settingsFile, "Variables", "NextDigWait")
        IniWrite(startY, settingsFile, "Variables", "StartY")
        IniWrite(endY, settingsFile, "Variables", "EndY")

    } catch as e {
    }
}

CreateMainGui() {
    global mainGui, tooltipCheckbox, cycleText, autoSellCheckbox, autoSellInput, walkTimeInput, nextDigWaitInput, oneTimeDigFullCheckbox, startYInput, endYInput, startY, endY
    
    mainGui := Gui("+AlwaysOnTop -MinimizeBox -Resize", "Moris prospecting macro v1.5 (modified by Hecta)")
    mainGui.BackColor := "F0F0F0"

    mainGui.SetFont("s10 Norm", "Segoe UI")

    mainGui.MarginX := 0
    mainGui.MarginY := 0

    mainGui.Add("GroupBox", "x7 y0 w124 h95 Section", "Autosell")
    autoSellCheckbox := mainGui.Add("Checkbox", "xs+10 ys+25 h25 Checked" . (autoSellEnabled ? "1" : "0"), "Enable Autosell")
    autoSellCheckbox.OnEvent("Click", ToggleAutoSell)
    
    mainGui.Add("Text", "xs+10 ys+55 w80 h23 +0x200", "Sell After:")
    autoSellInput := mainGui.Add("Edit", "xs+75 ys+55 w40 h25 Number Limit3 Center", autoSellCycles)
    autoSellInput.OnEvent("Change", UpdateAutoSellCycles)

    mainGui.Add("GroupBox", "x140 y0 w150 h125 Section", "Other") ; Increased width

    tooltipCheckbox := mainGui.Add("Checkbox", "xs+10 ys+25 h25 Checked" . (showDebugTooltips ? "1" : "0"), "Debug Tooltips")
    tooltipCheckbox.OnEvent("Click", ToggleTooltips)
    
    oneTimeDigFullCheckbox := mainGui.Add("Checkbox", "xs+10 y+5 h25 Checked" . (oneTimeDigFull ? "1" : "0"), "One Time Dig")
    oneTimeDigFullCheckbox.OnEvent("Click", ToggleOneTimeDigFull)

    mainGui.Add("Text", "xs+10 ys+85 w80 h23 +0x200", "Cycles:")
    cycleText := mainGui.Add("Text", "xs+59 ys+88 w50 h23 +Border +Center +0x200 BackgroundWhite c003366", cycleCount)
    cycleText.SetFont("s11 Bold", "Consolas")

    mainGui.Add("GroupBox", "x295 y0 w260 h95 Section", "Variables") ; Increased width and moved

    mainGui.Add("Text", "xs+10 ys+25 w70 h23 +0x200", "Walk Time:")
    walkTimeInput := mainGui.Add("Edit", "xs+75 ys+25 w40 h25 Number Limit4 Center", walkTime)
    walkTimeInput.OnEvent("Change", UpdateWalkTime)
    
    mainGui.Add("Text", "xs+10 ys+55 w70 h23 +0x200", "Dig Wait:")
    nextDigWaitInput := mainGui.Add("Edit", "xs+75 ys+55 w40 h25 Number Limit4 Center", nextDigWait)
    nextDigWaitInput.OnEvent("Change", UpdateNextDigWait)
    
    mainGui.Add("Text", "xs+130 ys+25 w75 h23 +0x200", "Start Dig Y:")
    startYInput := mainGui.Add("Edit", "xs+210 ys+25 w40 h25 Number Limit4 Center", startY)
    startYInput.OnEvent("Change", UpdateStartY)
    
    mainGui.Add("Text", "xs+130 ys+55 w75 h23 +0x200", "End Dig Y:")
    endYInput := mainGui.Add("Edit", "xs+210 ys+55 w40 h25 Number Limit4 Center", endY)
    endYInput.OnEvent("Change", UpdateEndY)

    mainGui.OnEvent("Close", GuiClose)
    mainGui.OnEvent("Escape", GuiClose)

    ;mainGui.Show("x-7 y630 w530 h120") ; Increased width and height
    mainGui.Show("x-7 y630 w570 h140")
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

ToggleOneTimeDigFull(*) {
    global oneTimeDigFull, oneTimeDigFullCheckbox
    oneTimeDigFull := oneTimeDigFullCheckbox.Value
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

UpdateWalkTime(*) {
    global walkTime, walkTimeInput
    try {
        newValue := Integer(walkTimeInput.Text)
        if (newValue >= 0) {
            walkTime := newValue
            SaveSettings()
        }
    } catch {
        walkTimeInput.Text := walkTime
    }
}

UpdateNextDigWait(*) {
    global nextDigWait, nextDigWaitInput
    try {
        newValue := Integer(nextDigWaitInput.Text)
        if (newValue >= 0) {
            nextDigWait := newValue
            SaveSettings()
        }
    } catch {
        nextDigWaitInput.Text := nextDigWait
    }
}

UpdateDetectionX(*) {
    global detectionX, detectionXInput
    try {
        newValue := Integer(detectionXInput.Text)
        if (newValue >= 0) {
            detectionX := newValue
            SaveSettings()
        }
    } catch {
        detectionXInput.Text := detectionX
    }
}

UpdateStartY(*) {
    global startY, startYInput
    try {
        newValue := Integer(startYInput.Text)
        if (newValue >= 0) {
            startY := newValue
            SaveSettings()
        }
    } catch {
        startYInput.Text := startY
    }
}

UpdateEndY(*) {
    global endY, endYInput
    try {
        newValue := Integer(endYInput.Text)
        if (newValue >= 0) {
            endY := newValue
            SaveSettings()
        }
    } catch {
        endYInput.Text := endY
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
