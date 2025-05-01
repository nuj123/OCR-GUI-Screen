#Requires Autohotkey v2

_AHK := "OCR GUI Class With Execution.ahk ahk_class AutoHotkeyGUI"
_EXE := "OCR GUI Class With Execution.exe ahk_class AutoHotkeyGUI"
log_it := ""

try {
    WinGetPos(&_AHKx, &_AHKy, &_AHKw, &_AHKh, _AHK)
    log_it := "AHK: (" . _AHKx . ", " . _AHKy . ", " . _AHKw . ", " . _AHKh ")`n"
}
catch as e {
    _AHK := ""
}
try {
    WinGetPos(&_EXEx, &_EXEy, &_EXEw, &_EXEh, _EXE)
    log_it .= "EXE: (" . _EXEx . ", " . _EXEy . ", " . _EXEw . ", " . _EXEh ")"
}
catch as e {
    _EXE := ""
}

if !(log_it)
    log_it := "Neither .AHK or .EXE GUI windows were found."

MsgBox( log_it )

