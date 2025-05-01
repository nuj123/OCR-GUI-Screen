#Requires Autohotkey v2

MsgBox( GetFileNames() )


GetFileNames() {
    log_it := ""
    Loop Files, A_ScriptDir "\*.*", "F" {
        SplitPath(A_LoopFileName, , , &fileExe , &fileName )

        if !(fileExe = "ahk") && !(fileExe = "exe")
            continue

        if (A_LoopField = A_SCRIPTName)
            continue

        _AHK := A_LoopFileName " ahk_class AutoHotkeyGUI"

        try {
            WinGetPos(&_AHKx, &_AHKy, &_AHKw, &_AHKh, _AHK)
            if !(log_it)
                log_it := "Name: (x,y,w,h)`n--------------------------`n"

            log_it .= A_LoopFileName ":     (" . _AHKx . "," . _AHKy . "," . _AHKw . "," . _AHKh ")`n"
        }

    }

    If !(log_it)
        log_it := "No ahk windows in the current directory were found running."

    return log_it

}