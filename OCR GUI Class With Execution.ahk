#Requires AutoHotkey v2
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir

#Warn All, StdOut
#ErrorStdOut 'UTF-8'

#include %A_WorkingDir%\Lib\OCR.ahk
#Include %A_WorkingDir%\Lib\print_debug.ahk
#include %A_WorkingDir%\Lib\fuzzy.ahk
#include %A_WorkingDir%\Lib\gtranslate.ahk
#include %A_WorkingDir%\Lib\_JXON.ahk

CoordMode('Pixel', 'Screen')
CoordMode('Mouse', 'Screen')
CoordMode('ToolTip', 'Screen')

goTL := ScreenTL()

; #50B9FE   BLUE - VARIABLES
; #529955   GREEN - STRINGS
; #33BBB0   BlueGreen - CLASS
; #FF2D10  RED - TODO !
; #6A9955   Comments

class ScreenTL
{
    config_fileName := A_ScriptDir "/SCREEN_OCR_config.ini"
    __New() {

        OnError(LogError)

        ; this.LoadConfigs(1,1)

        this.guiStartUP := Gui()
        ; this.guiStartup.SetFont("c529955")

        this.guiStartup.BackColor := 0x202020
        this.guiStartUP.Opt("+DPIScale")
        this.guiSB := this.guiStartUP.Add("StatusBar",, "Hi")
        this.Log("Initializing...")
        this.Initialize()
        this.guiStartUP.SetFont("w700 c50B9FE")


        if (this.var_showNotes) {

                this.guiStartUP.SetFont("w700")
                this.guiStartUP.Add("Text", "section Center w" this.Gui_CTRL_WIDTH,"Description")

                for k, v in this.varMessageIntro() {
                    if InStr(v, ":")
                        this.guiStartUP.SetFont("w700 c50B9FE")
                    else
                        this.guiStartUP.SetFont("w400 c529955")

                    this.guiStartUP.Add("Text", "w" this.Gui_CTRL_WIDTH, v)
                }

                this.guiStartUP.Add("Text", "ys section center w" this.Gui_CTRL_WIDTH " cFF2D10", "DISCLAIMER!")

                for k, v in this.varMessageWarning() {
                    if InStr(v, "->") {
                        this.langSettings := this.GuiStartup.Add("Button", "w" this.Gui_CTRL_WIDTH, v)
                        this.langSettings.OnEvent("Click", ObjBindMethod(this, "OpenLangSettings"))

                    }
                    else
                        this.guiStartUP.Add("Text", "w" this.Gui_CTRL_WIDTH " cFF2D10", v)
                }

        }

        this.guiStartUP.SetFont("w400")
        this.guiStartUP.SetFont("w700 c6A9955")
        ; checkbox to hide/show notes
        newSection:= this.Var_ShowNotes ? "ys" : ""
        v_checkBox := (this.var_showNotes ? "checked" : "")
        this.chkNotes := this.guiStartUP.Add("CheckBox", newSection " section vChkBox_showNotes " v_checkBox, "Show Notes? (Script will reload)")
        this.chkNotes.OnEvent("Click", ObjBindMethod(this, "ToggleNotes"))

        this.guiStartUP.SetFont("w700")
        this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "Language to OCR in UWP")

        this.guiStartUP.SetFont("w400")

        this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "(Preinstalled Languages only!)")
        this.txt_OCR := this.guiStartUP.Add("Text", "w" this.Gui_CTRL_WIDTH, "OCR Language:")

        this.GenerateList()

        this.LANG_LIST := this.ListOfInstalledLanguages()

        this.ddl_OCR := this.guiStartup.Add("DDL", "vDDLvar w" this.Gui_CTRL_WIDTH " ", this.LANG_LIST)
        this.ddl_OCR.OnEvent("Change", ObjBindMethod(this, "SaveConfigs"))

        this.guiStartUP.Add("Text")

        this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "EXPERIMENTAL")
        this.guiStartUP.SetFont("w400")

        if !(A_IsAdmin) {
            this.guiStartUP.Add("Text", "w" this.Gui_CTRL_WIDTH, "View list of Available OCR Languages to download?`n`nTo see list, script must start with admin rights.")
            this.OCR_Available_DL_Languages := this.guiStartUP.Add("Button", "w" this.Gui_CTRL_WIDTH " ", "> Click Here to Load List! <`nAdmin privileges needed!`n`n After you select [Yes] on the UAC, a blue window will pop up briefly before disappearing. That is normal!")
            ; handler := .bind(this, "PowerShellList").

            this.OCR_Available_DL_Languages.OnEvent("Click", ObjBindMethod(this, "PowerShellList"))
        } else {
            ddl_OCR_Avail := []
            for k, v in this.PowerShellList(1,1)
            {
                if (v = "`n") || !(v)
                    continue

                ddl_OCR_Avail.Push(v)
            }

            this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "Use Powershell to download/remove the selected language:")
            this.OCR_Available_DL_Languages := this.guiStartUP.Add("DDL", "vDDLAvail w" this.Gui_CTRL_WIDTH , ddl_ocr_Avail)
            this.OCR_Available_DL_Languages.OnEvent("Change", ObjBindMethod(this, "SaveConfigs"))

            this.Btn_DL_Language := this.guiStartUP.Add("Button", "w" this.Gui_CTRL_WIDTH , "DOWNLOAD selected Language!")
            this.Btn_DL_Language.OnEvent("Click", ObjBindMethod(this, "DL_Language"))

            this.Btn_RMV_Language := this.guiStartUP.Add("Button", "w" this.Gui_CTRL_WIDTH , "REMOVE selected Language!")
            this.Btn_RMV_Language.OnEvent("Click", ObjBindMethod(this, "RMV_Language"))
        }

        this.guiStartUP.SetFont("c33BBB0")
        this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH)
        this.guiStartUP.SetFont("w700")


        this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "Now for the Google Translate Languages!")
        this.guiStartUP.SetFont("w400")
        this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "Native/Source Language")
        this.txt_TLFROM := this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "TL FROM:" )
        this.ddl_src    := this.guiStartUP.Add("ddl","vddl_src_var w" this.Gui_CTRL_WIDTH, this.gListSrc)
        this.ddl_src.OnEvent("Change", ObjBindMethod(this, "SaveConfigs"))

        this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "Note: Google Language Codes are different for UWP Language Code, even though it's the same language. The UWP & Google language MUST MATCH for best results! Set to Auto-Detect for best compability?")

        this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "Output Language")

        this.txt_TLTO := this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "TL TO:")
        this.ddl_dest := this.guiStartUP.Add("ddl","vddl_src_dest w" this.Gui_CTRL_WIDTH, this.gListDest)
        this.ddl_dest.OnEvent("Change", ObjBindMethod(this, "SaveConfigs"))

        this.guiStartUP.Add("Text" , "section ys ")
        this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "Click button below to start OCR")
        this.btn_START := this.guiStartUP.Add("Button", "w" this.Gui_CTRL_WIDTH, "START OCR!")
        this.btn_START.OnEvent("Click", ObjBindMethod(this, "StartOCR"))
        ; TODO: on start, disable three dropdowns
        ; disable all othe fields.
        ;


        this.guiStartUP.Add("Text")
        this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "Click button below to stop OCR")
        this.btn_STOP := this.guiStartUP.Add("Button", "w" this.Gui_CTRL_WIDTH, "Stop OCR")

        ; TODO: On stop, enable three dropdowns
        ; enable all other fields.

        ; edit box to type in window Title
        this.guiStartUP.Add("Text"
                        , " w" this.Gui_CTRL_WIDTH,
                        'The title of the Window to focus on. Set to "A" for active window. You can specify "ahk_exe notepad.exe" to focus on the process name. For example, for "notepad.exe", you would put in "ahk_exe notepad.exe" ')
        this.edit_winTitle := this.guiStartUP.Add("Edit", "center w" this.Gui_CTRL_WIDTH " vVar_WinTitle", "A")
        this.edit_winTitle.OnEvent("Change", ObjBindMethod(this, "SetWinTitle"))


        ; maybe a listview box using WinGet?
        this.LoadConfigs(1,1)

        this.guiStartUP.Show()
        this.guiStartUP.OnEvent("Close", ObjBindMethod(this, "OnGuiClose"))


    }

    SetWinTitle(callback, info) {
        SetTimer(ObjBindMethod(this, "SaveConfigs").Bind(1,1), -200)
        this.Log("Saving Window Title...")
    }

    StartOCR(callback, info) {
        this.Log("Starting OCR")
        this.SaveConfigs(1,1)
        ; this.guiStartUP.submit(1)
        ; this.chkNotes.Value

        ; vOCR := this.ddl_OCR.Value
        ; vgTS := this.ddl_src.Value
        ; vgTD := this.ddl_dest.Value

        ; need to regexmatch just the [value] in both vgTS and vgTD
        ; this.ddl_OCR.Value:  fr-FR
        ; this.ddl_src.Value:  Auto Detect [auto]
        ; this.ddl_dest.Value: English_United_States [en]
        if (this.ddl_src.Value)
            RegExMatch(this.gListSrc[this.ddl_src.Value], "^.*?\[(.*?)\]", &matchSrc)

        this.Log("Google Source Selection: " this.ddl_src.value)
        if (this.ddl_dest.Value)
            RegExMatch(this.gListDest[this.ddl_dest.Value], "^.*?\[(.*?)\]", &matchDest)
        this.Log("Google Destination Selection: " this.ddl_dest.value)


        this.Log(
            "this.ddl_OCR.Value:  " this.LANG_LIST[this.ddl_OCR.Value] "`n"
            "this.ddl_src.Value:  " (this.ddl_src.Value ? matchSrc[1] : 0) "`n"
            "this.ddl_dest.Value: " (this.ddl_dest.Value ? matchDest[1] : 0) "`n"
            "this.ddl_dest.Value: " this.edit_winTitle.Value "`n"
        )
        ; disable fields

        ; retrievew variables
        ; start OCR
    }

    EndOCR(callback, info) {
        this.Log("OCR Stopped!")
        ; Enable Fields
        ; stop OCR
    }

    BtnDisableFields(callback, info) {

    }

    BtnEnableFields(callback, info) {


    }

    Log(str, prefix := "") {
        time := "[" A_Hour ":" A_Min ":" A_Sec "]: "
        this.guiSB.SetText(time . prefix . str)
    }

    OnGuiClose(*) {
        ExitApp
    }

    ToggleNotes(callback, info) {
        this.Log('Toggling "Show Notes"')
        this.guiStartUP.Submit(0)

        this.var_showNotes := this.chkNotes.Value
        this.SaveConfigs(1,1)
        Reload
    }

    LogError(errObj, mode) {

        errMsg := format("
        (
            --------------------------------------
            Error: {5}
            {1} [{2}] {3}

            Stack: {4}
        )",errObj.File, errObj.Line, errObj.What, errObj.Stack, errObj.Message)

        This.Log(errMsg, "[ERROR] ")
    }

    SaveConfigs(callback, info) {
        this.Log("Saving Configs")
        this.guiStartUP.Submit(0)

        try {
            IniWrite(this.ddl_OCR.Text,  this.config_fileName, "OCR", "UWP")
            IniWrite(this.ddl_src.Text,  this.config_fileName, "OCR", "gTL_FROM")
            IniWrite(this.ddl_dest.Text, this.config_fileName, "OCR", "gTL_TO")

            IniWrite(this.chkNotes.Value, this.config_fileName, "Settings","ShowNotes")
            IniWrite(this.edit_winTitle.Value, this.config_fileName, "Settings", "TargetWindow")
        }
        catch as e {
            this.Log("Saving Error: " e.What A_Tab e.Message)
        }
    }

    LoadConfigs(callback, info) {

        ; auto-select default configurations
        this.Log("Loading configs")

        try {

            var_OCR   := IniRead(this.config_fileName, "OCR","UWP", "en-US")
            this.Log("Saved OCR Language: " var_OCR)

            this.Log("Attempting to load OCR Language: " var_OCR)
            this.ddl_OCR.choose(var_OCR)
        } catch {
            this.Log("Failed to load OCR Language: " var_OCR ". Choosing first available language.")
            this.ddl_OCR.choose(1)
        }

        try
        {
            var_gSrc  := IniRead(this.config_fileName, "OCR","gTL_FROM", "Auto Detect [auto]")
            this.Log("Saved Language to translate from: " var_gSrc)

            this.Log("Attempting to choose on drop down list: " var_gSrc)
            this.ddl_src.choose(var_gSrc)
        } catch {
            this.Log("Failed to load SOURCE language. Setting as 'Auto Detect'")
            this.ddl_src.choose(1)
        }

        try
        {
            var_gDest := IniRead(this.config_fileName, "OCR","gTL_TO", "en")
            this.Log("Saved Language to translate from: " var_gDest)

            this.Log("Attempting to choose on drop down list: " var_gDest)
            this.ddl_dest.choose(var_gDest)
        } catch {
            this.Log("Failed to load DESTINATION language. Setting as first available language.")
            this.ddl_dest.choose(1)
        }

        try
        {
            var_CheckNotes    := IniRead(this.config_fileName, "Settings","ShowNotes", 1)
            this.var_ShowNotes := var_checkNotes

            var_TargetWindows := IniRead(this.config_fileName, "Settings", "TargetWindow", "A")
            this.edit_winTitle.Value := var_TargetWindows
       }
        catch as e {
            MsgBox("Loading Error: " e.What)
        }
    }

    Initialize() {
        this.Log("Initializing")
        ; try {
            ; throw Error("Fail", -1)
            this.var_ShowNotes := IniRead(this.config_fileName, "Settings","ShowNotes", 1)
            this.Gui_WIDTH := 300
            this.Gui_CTRL_WIDTH := this.GUI_WIDTH - 20
            
        ; } catch as e {
        ;     MsgBox(
        ;         "Message: " e.Message "`n-----`n"

        ;         "What:" e.What "`n-----`n"

        ;         "Extra:" e.Extra "`n-----`n"

        ;         "File:" e.File "`n-----`n"

        ;         "Line:" e.Line "`n-----`n"
        ;         "Stack:" e.Stack "`n-----`n"
        ;     )
        ; }
    }

    GenerateList() {
        ; Generates UWP OCR Lists of Installed Languages
        this.LANG_LIST := this.ListOfInstalledLanguages()
        ; this.LANG_LIST.Pop()

        ; generates Google TL list
        this.gListSrc := []
        for index, arr in this.GoogleLanguageList() {
            this.gListSrc.Push(arr[1] " [" arr[3] "]")
        }

        this.gListDest := this.gListSrc.Clone()
        this.gListSrc.InsertAt(1,"Auto Detect [auto]")
    }

    RefreshDDL() {
        this.guiStartUP.submit

        this.GenerateList()
        this.ddl_OCR.delete()
        this.ddl_OCR.add(this.LANG_LIST)

        this.ddl_src.delete()
        this.ddl_src.add(this.gListSrc)

        this.ddl_dest.delete()
        this.ddl_dest.add(this.gListDest)

        this.txt_OCR.Text := "Changing OCR Language: " this.GetOcrLanguageName(this.ddl_OCR.Text)

        this.guiStartup.Show
    }

    RMV_Language(callback, info) {
        this.guiStartUP.submit
        this.SaveConfigs(1,1)

        {

            language_basic_var := this.OCR_Available_DL_Languages.Text

            psCommand := Format(
                'Remove-WindowsCapability -Online -Name "{1}"',
                language_basic_var
            )

            this.guiStartUP.Hide()
            this.powershellWait(psCommand)
        }
            this.RefreshDDL()
            this.LoadConfigs(1,1)
    }

    DL_Language(callback, info) {
        this.guiStartUP.submit
        this.SaveConfigs(1,1)

        language_basic_var := this.OCR_Available_DL_Languages.Text
        regex_needle := "~~~([^~]+)~"
        RegExMatch(language_basic_var, regex_needle, &MatchObj)
        language_abbrev := MatchObj[1]
        psCommand := Format(
            'Add-WindowsCapability -Online -Name "{}"', language_basic_var
        )
        this.guiStartUP.Hide()
        this.powershellWait(psCommand)

            LANG_LIST := this.ListOfInstalledLanguages()
            this.RefreshDDL
            this.LoadConfigs(1,1)
    }

    GetOcrLanguageName(capability) {
        local m, culture
        if !RegExMatch(capability, '~~~([^~]+)~', &m)
            return ""
        culture := m[1]  ; e.g. "ja-JP"

        ; LCTYPE constants
        LOCALE_SENGLANGUAGE := 0x1001
        LOCALE_SENGCOUNTRY  := 0x1002

        ; 1) Allocate a 512-byte buffer (enough for 256 UTF-16 chars)
        bufBytes  := 512
        bufChars  := bufBytes // 2
        langBuf   := Buffer(bufBytes)
        ctryBuf   := Buffer(bufBytes)

        ; 2) Call the API with the char‐count, not byte‐count
        DllCall(
        "Kernel32.dll\GetLocaleInfoEx"
        , "WStr",  culture
        , "UInt",  LOCALE_SENGLANGUAGE
        , "Ptr",   langBuf.Ptr
        , "Int",   bufChars
        )
        DllCall(
        "Kernel32.dll\GetLocaleInfoEx"
        , "WStr",  culture
        , "UInt",  LOCALE_SENGCOUNTRY
        , "Ptr",   ctryBuf.Ptr
        , "Int",   bufChars
        )

        ; 3) Read the full null-terminated UTF-16 string
        lang := StrGet(langBuf.Ptr, "UTF-16")
        ctry := StrGet(ctryBuf.Ptr, "UTF-16")

        return lang " (" ctry ")"   ; e.g. "Japanese (Japan)"
    }

    OpenLangSettings(callback, info) {
        try Run "ms-settings:regionlanguage"
    }

    PowerShellList(ctrl, info) {
        ; --- Relaunch script with admin privileges if not already ---
        if !A_IsAdmin {
            try {
                ; MsgBox("Relaunching script as admin! Admin privileges are needed to view the list of currently downloadable languages!")
                Run '*RunAs "' A_AHKPath '" "' A_ScriptFullPath '"'
            } catch as e {
                MsgBox "Failed to run as admin: " e.Message
                ExitApp
            }
            ExitApp
        }

        AvailableLanguages := this.powershellListOfAllAvailableLanguages()

        return StrSplit(AvailableLanguages, "`n", "`r")
    }

    varMessageIntro() {
        var := "
        (
            This script operates in three phases.
            PHASE 1: TEXT EXTRACTION - UWP OCR
            To minimize installations of outside programs, this script taps into an OCR engine present in the Universal Windows Platform (UWP) API, specifically, the "Windows.Media.OCR" namespace. This is only available in Windows 10 and above.
            To be able to extract the text, the appropriate language MUST be installed on your computer.
            PHASE 2: TEXT PARSING and TRANSLATING
            With the text retrieved from the OCR engine, the words are all joined together for one massive translation.
            Translation is done through the Google Translate API.
            PHASE 3: DISPLAY
            The UWP OCR stores the positions of the lines it decoded. AHK now uses those position, along with the newly translated lines, to draw the on screen.
            The drawing is done via an AHK GUI. The background is set to be transparent, and only the Texts are drawn, respective to their word locations.
        )"

        newVar := StrSplit(var, "`n")
        return newVar
    }

    varMessageWarning() {
        var := "
        (
            - OCR is not 100% accurate!
            - Minimum height of text to be extracted for OCR is 12 pixels for a 1024x768! (About 8-pt font text at 150 DPI)
            - UWP only supports a small subset of languages (35 languages) for OCR. It does NOT SUPPORT mixed-language OCR. It can only do one language at a time, and it can't mix language.
            - You must have the "language to be OCR" installed!
            - UWP does not handle languages with complex scripts (Arabic/Japanese/Chinese/etc) very well.
            - Performance is limited by the local machine's processing power.
            - INTERNET ACCESS REQUIRED to view list of "Available Languages to Download"!
            - WINDOWS 10 and ABOVE only!
            - The [Download] buttons on the right are experimental only, and if they don't work, please install the Language Package the normal way.
            [Start] -> [Language Settings] -> [+] Add a Language -> Choose your language.
        )"
        newVar := StrSplit(var, "`n")
        return newVar
    }

    powershellOutput(psCommand := "") {
        ; --- RUN POWERSHELL AND CAPTURE OUTPUT ---
        try {
            fullCmd := 'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "' psCommand '"'
            shell := ComObject("WScript.Shell")
            exec  := shell.Exec(fullCmd)

            ; — block until PS exits (Status: 1=running, 2=finished)
            while (exec.Status = 1)
            {
                Sleep 100
                MsgBox(exec.StdOut.ReadAll())
            }

            ; — read whatever was written to stdout/stderr
            out := exec.StdOut.ReadAll()
            err := exec.StdErr.ReadAll()
            if (err)
                out .= "`n**ERROR**: " err

            return out
        } catch as e {
            MsgBox("Error in PowerShell call: " e.Message)
            ExitApp
        }

    ; no captured text, but you know it’s done

    }

; TODO: Adjust Tooltip for RUNWAIT
    powerShellWait(psCommand := "") {
        fullCmd := 'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "' psCommand '"'
        this.outPID := ""
        tempTimer := ObjBindMethod(this, "TT").Bind("Please wait for POWERSHELL operations to be completed...")
        SetTimer(tempTimer, 50)
        try RunWait(fullCmd, "","", &outPID)
        catch as e {
            MsgBox("Error: " e.message)
        }
        SetTimer(tempTimer, 0)
        this.TT("Completed! Relaunching GUI!")
        SetTimer(ObjBindMethod(this,"TT_OFF"),-1500)
        return 1
    }

    TT(str := "") {
        CoordMode("TooLtip", "Screen")
        CoordMode("Mouse", "Screen")
        MouseGetPos(&x, &y)
        ToolTip(str, x - 80, y + 40)
    }

    TT_OFF() {
        ToolTip()
    }


    powershellListOfInstalledLanguages() {
            ; Get-WinUILanguageList | ForEach-Object { $_.LanguageTag }
            psCommand := "
            (
                Get-WindowsCapability -Online | Where-Object Name -Like 'Language.OCR*'| Select-Object Name, State
            )"
            return this.powershellOutput(psCommand)
    }

    powershellListOfAllAvailableLanguages() {
        ; --- POWERHELL COMMAND TO GET LANGUAGES ---
        ; Retrieves list of all available OCR language to download
        psCommand := "
        (
            Get-WindowsCapability -Online | Where-Object { $_.Name -like 'Language.OCR*' } | Select-Object -ExpandProperty Name
        )"
        return this.powershellOutput(psCommand)
    }

    ListOfInstalledLanguages() {
        var := OCR.GetAvailableLanguages()
        newarr := []
        for k, v in StrSplit(var, "`n")
        {
            if (v = "`n") || !(v)
                continue
            newarr.Push(v)

        }
        return newArr
    }

    GoogleLanguageList() {
        LanguageCodeArray :=
        [   ["Afrikaans","0436","af"],
            ["Albanian","041c","sq"],
            ["Arabic_Saudi_Arabia","0401","ar"],
            ["Arabic_Iraq","0801","ar"],
            ["Arabic_Egypt","0c01","ar"],
            ["Arabic_Libya","1001","ar"],
            ["Arabic_Algeria","1401","ar"],
            ["Arabic_Morocco","1801","ar"],
            ["Arabic_Tunisia","1c01","ar"],
            ["Arabic_Oman","2001","ar"],
            ["Arabic_Yemen","2401","ar"],
            ["Arabic_Syria","2801","ar"],
            ["Arabic_Jordan","2c01","ar"],
            ["Arabic_Lebanon","3001","ar"],
            ["Arabic_Kuwait","3401","ar"],
            ["Arabic_UAE","3801","ar"],
            ["Arabic_Bahrain","3c01","ar"],
            ["Azeri_Latin","042c","az"],
            ["Azeri_Cyrillic","082c","az"],
            ["Basque","042d","eu"],
            ["Belarusian","0423","be"],
            ["Bulgarian","0402","bg"],
            ["Catalan","0403","ca"],
            ["Chinese_Taiwan","0404","zh-CN"],
            ["Chinese_PRC","0804","zh-CN"],
            ["Chinese_Hong_Kong","0c04","zh-CN"],
            ["Chinese_Singapore","1004","zh-CN"],
            ["Chinese_Macau","1404","zh-CN"],
            ["Croatian","041a","hr"],
            ["Czech","0405","cs"],
            ["Danish","0406","da"],
            ["Dutch_Standard","0413","nl"],
            ["Dutch_Belgian","0813","nl"],
            ["English_United_States","0409","en"],
            ["English_United_Kingdom","0809","en"],
            ["English_Australian","0c09","en"],
            ["English_Canadian","1009","en"],
            ["English_New_Zealand","1409","en"],
            ["English_Irish","1809","en"],
            ["English_South_Africa","1c09","en"],
            ["English_Jamaica","2009","en"],
            ["English_Caribbean","2409","en"],
            ["English_Belize","2809","en"],
            ["English_Trinidad","2c09","en"],
            ["English_Zimbabwe","3009","en"],
            ["English_Philippines","3409","en"],
            ["Estonian","0425","et"],
            ["Finnish","040b","fi"],
            ["French_Standard","040c","fr"],
            ["French_Belgian","080c","fr"],
            ["French_Canadian","0c0c","fr"],
            ["French_Swiss","100c","fr"],
            ["French_Luxembourg","140c","fr"],
            ["French_Monaco","180c","fr"],
            ["Georgian","0437","ka"],
            ["German_Standard","0407","de"],
            ["German_Swiss","0807","de"],
            ["German_Austrian","0c07","de"],
            ["German_Luxembourg","1007","de"],
            ["German_Liechtenstein","1407","de"],
            ["Greek","0408","el"],
            ["Hebrew","040d","iw"],
            ["Hindi","0439","hi"],
            ["Hungarian","040e","hu"],
            ["Icelandic","040f","is"],
            ["Indonesian","0421","id"],
            ["Italian_Standard","0410","it"],
            ["Italian_Swiss","0810","it"],
            ["Japanese","0411","ja"],
            ["Korean","0412","ko"],
            ["Latvian","0426","lv"],
            ["Lithuanian","0427","lt"],
            ["Macedonian","042f","mk"],
            ["Malay_Malaysia","043e","ms"],
            ["Malay_Brunei_Darussalam","083e","ms"],
            ["Norwegian_Bokmal","0414","no"],
            ["Norwegian_Nynorsk","0814","no"],
            ["Polish","0415","pl"],
            ["Portuguese_Brazilian","0416","pt"],
            ["Portuguese_Standard","0816","pt"],
            ["Romanian","0418","ro"],
            ["Russian","0419","ru"],
            ["Serbian_Latin","081a","sr"],
            ["Serbian_Cyrillic","0c1a","sr"],
            ["Slovak","041b","sk"],
            ["Slovenian","0424","sl"],
            ["Spanish_Traditional_Sort","040a","es"],
            ["Spanish_Mexican","080a","es"],
            ["Spanish_Modern_Sort","0c0a","es"],
            ["Spanish_Guatemala","100a","es"],
            ["Spanish_Costa_Rica","140a","es"],
            ["Spanish_Panama","180a","es"],
            ["Spanish_Dominican_Republic","1c0a","es"],
            ["Spanish_Venezuela","200a","es"],
            ["Spanish_Colombia","240a","es"],
            ["Spanish_Peru","280a","es"],
            ["Spanish_Argentina","2c0a","es"],
            ["Spanish_Ecuador","300a","es"],
            ["Spanish_Chile","340a","es"],
            ["Spanish_Uruguay","380a","es"],
            ["Spanish_Paraguay","3c0a","es"],
            ["Spanish_Bolivia","400a","es"],
            ["Spanish_El_Salvador","440a","es"],
            ["Spanish_Honduras","480a","es"],
            ["Spanish_Nicaragua","4c0a","es"],
            ["Spanish_Puerto_Rico","500a","es"],
            ["Swahili","0441","sw"],
            ["Swedish","041d","sv"],
            ["Swedish_Finland","081d","sv"],
            ["Tamil","0449","ta"],
            ["Thai","041e","th"],
            ["Turkish","041f","tr"],
            ["Ukrainian","0422","uk"],
            ["Urdu","0420","ur"],
            ["Vietnamese","042a","vi"]]

            return LanguageCodeArray
    }
}


*F8::Reload


*F12::ExitApp
