#Requires AutoHotkey v2
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir 

; adds icon to compiled script 
;@Ahk2Exe-AddResource %A_ScriptDir%\Fish.ico, 14
; TraySetIcon("Fish.ico", 1)

#Warn All, Off
#ErrorStdOut 'UTF-8'

#include F:\OneDrive\AHK\v2\OCR GUI Screen\Lib\OCR.ahk
#include F:\OneDrive\AHK\v2\OCR GUI Screen\Lib\fuzzy.ahk
#include F:\OneDrive\AHK\v2\OCR GUI Screen\Lib\gtranslate.ahk
#include F:\OneDrive\AHK\v2\OCR GUI Screen\Lib\_JXON.ahk

CoordMode('Pixel', 'Client')
CoordMode('Mouse', 'Screen')
CoordMode('ToolTip', 'Screen')

goTL := ScreenTL()

; #50B9FE   BLUE - VARIABLES
; #529955   GREEN - STRINGS
; #33BBB0   BlueGreen - CLASS
; #FF2D10   RED - TODO !
; #6A9955   Comments

/*
    Class: ScreenTL
    Description:
        This class provides functionality for performing OCR (Optical Character Recognition) on a screen, translating the extracted text using Google Translate API, 
        and displaying the translated text as an overlay on the screen. It includes GUI elements for configuration, language selection, and customization of the overlay.

    Properties:
        - config_fileName: Path to the configuration file.
        - OldOCRResult: Stores the previous OCR result for comparison.
        - toggle_start: Toggle state for starting OCR.
        - OldoutDetectWinX, OldoutDetectWinY, OldoutDetectWinWinID: Store previous window detection coordinates and ID.
        - oldUpDown_FontSize: Stores the previous font size.
        - oldFontOptions: Stores the previous font options.
        - Oldedit_colorTextBackground, Oldedit_colorTextFont: Store previous text and background colors.

    Methods:
        - __New(): Initializes the class, sets up the GUI, and loads configurations.
        - SetWinTitle(callback, info): Saves the window title to the configuration.
        - ExtractFromSquareBracket(str): Extracts text within square brackets from a string.
        - ReadScreen(callback, info): Performs OCR on the screen, translates the text, and displays it as an overlay.
        - GenerateGuiOverlay(): Creates a transparent GUI overlay for displaying translated text.
        - CursorWait(): Changes the cursor to a wait state.
        - CursorNormal(): Resets the cursor to the default state.
        - HideGuiOverlay(): Hides the GUI overlay.
        - StartOCR(callback, info): Starts the OCR process and sets up a timer for continuous reading.
        - EndOCR(callback, info): Stops the OCR process and disables the overlay.
        - FindWindowName(callback, info): Detects the name of the currently active window.
        - DetectWindowName(): Continuously detects the active window's title and process name.
        - Log(str, prefix): Logs messages to the status bar.
        - OnGuiClose(*): Handles the GUI close event and saves configurations.
        - ToggleNotes(callback, info): Toggles the visibility of notes and reloads the script.
        - LogError(errObj, mode): Logs error messages with details.
        - LimitToHex(ctrl): Ensures that input in a control is limited to valid hexadecimal values.
        - SaveConfigs(callback, info): Saves the current configurations to the INI file.
        - LoadConfigs(callback, info): Loads configurations from the INI file.
        - Initialize(): Initializes default values and settings.
        - GenerateList(): Generates lists of installed and available languages for OCR and translation.
        - RefreshDDL(): Refreshes the dropdown lists for language selection.
        - RMV_Language(callback, info): Removes a selected OCR language using PowerShell.
        - DL_Language(callback, info): Downloads a selected OCR language using PowerShell.
        - GetOcrLanguageName(capability): Retrieves the name of an OCR language from its capability string.
        - OpenLangSettings(callback, info): Opens the Windows Language & Region settings.
        - PowerShellList(ctrl, info): Retrieves a list of available OCR languages using PowerShell.
        - varMessageIntro(): Returns an array of introductory messages about the script's functionality.
        - varMessageWarning(): Returns an array of warning messages about the script's limitations.
        - powershellOutput(psCommand): Executes a PowerShell command and captures its output.
        - powerShellWait(psCommand): Executes a PowerShell command and waits for its completion.
        - TT(str): Displays a tooltip with the given message.
        - TT_OFF(): Hides the tooltip.
        - powershellListOfInstalledLanguages(): Retrieves a list of installed OCR languages using PowerShell.
        - powershellListOfAllAvailableLanguages(): Retrieves a list of all available OCR languages using PowerShell.
        - ListOfInstalledLanguages(): Retrieves a list of installed OCR languages using the OCR library.
        - GoogleLanguageList(): Returns a list of supported Google Translate languages with their codes.
        - FontOptions(): Returns a list of available font options for the overlay text.

    Notes:
        - The script uses UWP OCR for text extraction, which requires the appropriate language to be installed on the system.
        - Google Translate API is used for translation, requiring an internet connection.
        - The overlay is drawn using AHK GUI, with customizable font, size, and colors.
        - The script supports downloading and removing OCR languages via PowerShell.
        - Windows 10 or above is required for UWP OCR functionality.
*/
class ScreenTL
{

    config_fileName := A_ScriptDir "/SCREEN_OCR_config.ini"
    OldOCRResult := ""
    toggle_start := 0
    OldoutDetectWinX  := ""
    ; Initialize the variable to store the previous Y-coordinate of the detected window
    OldoutDetectWinY := ""
    OldoutDetectWinWinID := ""
    oldUpDown_FontSize := ""
    oldFontOptions := ""
    Oldedit_colorTextBackground := ""
    Oldedit_colorTextFont := ""

    __New() {
        ; this.LoadConfigs(1,1)
        pre := "[ON START] "


        this.guiStartUP := Gui()
        ; this.guiStartup.SetFont("c529955")

        this.guiStartup.BackColor := 0x202020
        this.guiStartUP.Opt("+DPIScale")
        this.guiSB := this.guiStartUP.Add("StatusBar",, "Hi")
        this.Log("Initializing...", pre)
        this.GenerateGuiOverlay
        this.Initialize()

        this.guiStartUP.SetFont("w700 c50B9FE")

        ; 
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

        this.GuiStartUp.Add("Text")
        this.guiStartUP.SetFont("w700")
        this.guiStartUP.Add("Text", "center section w" this.Gui_CTRL_WIDTH, "(1) Screen Read: OCR w/ UWP")

        this.guiStartUP.SetFont("w400")

        this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "(Preinstalled Languages only!)")
        this.txt_OCR := this.guiStartUP.Add("Text", "w" this.Gui_CTRL_WIDTH, "a) OCR Language:")

        this.GenerateList()

        this.LANG_LIST := this.ListOfInstalledLanguages()
        this.guiStartUP.SetFont("c1f00cc")
        this.ddl_OCR := this.guiStartup.Add("DDL", "vDDLvar w" this.Gui_CTRL_WIDTH " ", this.LANG_LIST)
        this.ddl_OCR.OnEvent("Change", ObjBindMethod(this, "SaveConfigs"))
        this.guiStartUP.SetFont("w700 c6A9955")
        this.guiStartUP.Add("Text")

        this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "EXPERIMENTAL")
        this.guiStartUP.SetFont("w400")

        if !(A_IsAdmin) {
            this.guiStartUP.Add("Text", "w" this.Gui_CTRL_WIDTH, "View list of Available OCR Languages to download?`n`nTo see list, script must start with admin rights.`nCurrent Admin Status: " (A_IsAdmin ? "Is Admin" : "Is NOT Admin"))
            this.OCR_Available_DL_Languages := this.guiStartUP.Add("Button", "w" this.Gui_CTRL_WIDTH " ", "> Click Here to Load List! <`nAdmin privileges needed!`n`n After you select [Yes] on the UAC, a blue window will pop up briefly before disappearing. That is normal!")
            ; handler := .bind(this, "PowerShellList").

            this.OCR_Available_DL_Languages.OnEvent("Click", ObjBindMethod(this, "PowerShellList"))
        } else {
            this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "Current Admin Status: " (A_IsAdmin ? "Is Admin" : "Is NOT Admin"))
            ddl_OCR_Avail := []
            for k, v in this.PowerShellList(1,1)
            {
                if (v = "`n") || !(v)
                    continue

                ddl_OCR_Avail.Push(v)
            }

            this.guiStartUP.Add("Text", " w" this.Gui_CTRL_WIDTH, "b) Use Powershell to download/remove the selected language in the drop down list below.")

            this.guiStartUP.SetFont("c1f00cc")
            this.OCR_Available_DL_Languages := this.guiStartUP.Add("DDL", "vDDLAvail w" this.Gui_CTRL_WIDTH , ddl_ocr_Avail)
            this.OCR_Available_DL_Languages.choose(1)
            this.OCR_Available_DL_Languages.OnEvent("Change", ObjBindMethod(this, "SaveConfigs"))
            this.guiStartUP.SetFont("w700 c6A9955")


            this.Btn_DL_Language := this.guiStartUP.Add("Button", "w" this.Gui_CTRL_WIDTH , "DOWNLOAD selected Language!")
            this.Btn_DL_Language.OnEvent("Click", ObjBindMethod(this, "DL_Language"))

            this.Btn_RMV_Language := this.guiStartUP.Add("Button", "w" this.Gui_CTRL_WIDTH , "REMOVE selected Language!")
            this.Btn_RMV_Language.OnEvent("Click", ObjBindMethod(this, "RMV_Language"))
        }

        ; this.guiStartUP.Add("Picture", "w" this.Gui_CTRL_WIDTH " h-1", A_ScriptDir "\Fish_Searching.png")

        this.guiStartUP.SetFont("c33BBB0")
        ; this.guiStartup.Add("Text", " section ys w" this.Gui_CTRL_WIDTH)
        this.guiStartUP.SetFont("w700")

        this.guiStartup.Add("Text", "section ys w" this.Gui_CTRL_WIDTH " center", "(2) Google Translate Language Settings")
        this.guiStartUP.SetFont("w400")
        this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "Native/Source Language")
        this.txt_TLFROM := this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "a) TL FROM:" )
        this.ddl_src    := this.guiStartUP.Add("ddl","vddl_src_var w" this.Gui_CTRL_WIDTH, this.gListSrc)
        this.ddl_src.OnEvent("Change", ObjBindMethod(this, "SaveConfigs"))

        this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "Note: Google Language Codes are different for UWP Language Code, even though it's the same language. The UWP & Google language MUST MATCH for best results! Set to Auto-Detect for best compability?")

        this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "Output Language")

        this.txt_TLTO := this.guiStartup.Add("Text", "w" this.Gui_CTRL_WIDTH, "b) TL TO:")
        this.ddl_dest := this.guiStartUP.Add("ddl","vddl_src_dest w" this.Gui_CTRL_WIDTH, this.gListDest)
        this.ddl_dest.OnEvent("Change", ObjBindMethod(this, "SaveConfigs"))

        ; this.guiStartUP.Add("Pic", "w" this.Gui_CTRL_WIDTH " h-1", A_ScriptDir "\Fish_Speaking.png")

        this.guiStartUP.SetFont("c4ecc35")
        ; this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "Click button below to start OCR")


        ; edit box to type in window Title
        this.guiStartUP.SetFont("w700")
        this.guiStartUP.Add("Text", "section ys w" this.Gui_CTRL_WIDTH, "(3) Drawing Overlay w/ AHK")
        this.guiStartUP.SetFont("w400")
        this.guiStartUP.Add("Text", " w" this.Gui_CTRL_WIDTH,
        '- The title of the Window to focus on.`n'
        '- Set to "A" for "any window that is active" .' "`n"
        '- You can specify "ahk_exe notepad.exe" to focus on the process name.' "`n"
        '- For example, for "notepad.exe", you would put in "ahk_exe notepad.exe" ')
        this.guiStartUP.Add("Text")

        this.btn_WINTITLE := this.guiStartUP.Add("Button", "w" this.Gui_CTRL_WIDTH, "Help Find Window Name")
        this.btn_WINTITLE.OnEvent("Click", ObjBindMethod(this, "FindWindowName"))

        this.RadioFull := this.guiStartUP.Add("Radio", "w" this.Gui_CTRL_WIDTH " ", "Use Full Window Title and Process Name")
        this.RadioWinT := this.guiStartUP.Add("Radio", "w" this.Gui_CTRL_WIDTH " ", "Use just Window Title")
        this.RadioEXE  := this.guiStartUP.Add("Radio", "w" this.Gui_CTRL_WIDTH " ", "Use just Process Name")

        ; this.RadioFull.Value := IniRead(this.config_fileName, "GUI", "RadioFull")
        ; this.RadioWinT.Value := IniRead(this.config_fileName, "GUI", "RadioWinT")
        ; this.RadioEXE.Value  := IniRead(this.config_fileName, "GUI", "RadioEXE")

        this.RadioFull.OnEvent("Click", ObjBindMethod(this, "SaveConfigs"))
        this.RadioWinT.OnEvent("Click", ObjBindMethod(this, "SaveConfigs"))
        this.RadioEXE.OnEvent("Click", ObjBindMethod(this, "SaveConfigs"))

        this.guiStartUP.SetFont("c1f00cc")
        this.edit_winTitle := this.guiStartUP.Add("Edit", " r3 center w" this.Gui_CTRL_WIDTH " vVar_WinTitle", "A")
        this.edit_winTitle.OnEvent("Change", ObjBindMethod(this, "SetWinTitle"))
        this.guiStartUP.SetFont("c4ecc35")

        this.chkShowOnActive := this.guiStartUP.Add("CheckBox", "","Show words only when the TARGET WINDOW is active?")
        this.chkShowOnActive.OnEvent("Click", ObjBindMethod(this, "SaveConfigs"))


        ; TODO FONT ADJUSTMENTS
        this.guiStartUP.Add("Text")
        this.guiStartUP.SetFont("w700")
        this.guiStartUP.Add("Text", "", "Font options for your OCR/TL!")
        this.guiStartUP.SetFont("w400")

        this.ddl_FontOptions := this.guiStartup.Add("ddl", "w" this.Gui_CTRL_WIDTH, this.FontOptions())
        this.ddl_fontOptions.OnEvent("Change", ObjBindMethod(this, "SaveConfigs"))

        this.guiStartUP.Add("Text")
        this.guiStartUP.Add("Text",,"Font Size: ")
        this.guiStartUP.Add("Text", "r2 center w" this.Gui_CTRL_WIDTH // 4, "")
        this.UpDown_FontSize := this.guiStartUP.Add("UpDown", "Left Range2-100", IniRead(this.config_fileName,"GUI", "UpDownFontSize", 14))
        this.UpDown_FontSize.OnEvent("Change", (*) => this.Log("Font Size Changed: " this.UpDown_FontSize.Value))
        this.guiStartUP.Add("Text", "w" this.Gui_CTRL_WIDTH // 2 " xp right", "FONT HEX color: 0x`n`nBKGRND HEX color: 0x")
        this.edit_colorTextFont := this.guiStartUP.Add("Edit", "w" (this.Gui_CTRL_WIDTH // 2 ) - 6 " limit6 yp", )
        this.edit_colorTextFont.OnEvent("Change", (*) => this.LimitToHex(this.edit_colorTextFont))


        this.edit_colorTextBackground := this.guiStartUP.Add("Edit",  "w" (this.Gui_CTRL_WIDTH // 2) - 6 " limit6 xp", )
        this.edit_colorTextBackground.OnEvent("Change", (*) => this.LimitToHex(this.edit_colorTextBackground))

        this.guiStartUP.Add("text", "xs w" this.Gui_CTRL_WIDTH, "Note: HEX Colors range from 0x000000 to 0xFFFFFF. To set a transparent color, use 'EEAA99' (Not Recommended). ")

        this.guiStartUP.Add("Text", "xs section")
        this.btn_START := this.guiStartUP.Add("Button", "xs w" this.Gui_CTRL_WIDTH, "START Screen Translation")
        this.btn_START.OnEvent("Click", ObjBindMethod(this, "StartOCR"))
        ;
        ; this.guiStartUP.Add("Text", "center w" this.Gui_CTRL_WIDTH, "Click button below to stop OCR")
        this.btn_STOP := this.guiStartUP.Add("Button", "xs w" this.Gui_CTRL_WIDTH, "STOP Screen Translation")
        this.btn_stop.OnEvent("Click", ObjBindMethod(this, "EndOCR"))
        ; maybe a listview box using WinGet?

        ; TODO: Edit Controls for:
        ; Text Color
        ; Background for Text color


        this.LoadConfigs(1,1)

        this.guiStartUP.Show("x" this.MainGuiX " y" this.MainGuiY)
        this.guiStartUP.OnEvent("Close", ObjBindMethod(this, "OnGuiClose"))

        this.btn_stop.Enabled := False
        this.edit_winTitle.Enabled := True

        this.StartTime := A_TickCount
        this.Log("Loaded Successfully!", pre)

    }

    SetWinTitle(callback, info) {
        SetTimer(ObjBindMethod(this, "SaveConfigs").Bind(1,1), -200)
        this.Log("Saving Window Title...")
    }

    ExtractFromSquareBracket(str) {
        RegExMatch(str, "^.*?\[(.*?)\]", &matchSrc)
        var := matchSrc[1]
        return var
    }

    ReadScreen(callback, info) {
        pre := "[READING]: "
        this.Log("Reading Screen", pre)
        this.edit_winTitle.Enabled := False
        if (WinActive(this.edit_winTitle.Value) && this.chkShowOnActive.Value) || (!(this.chkShowOnActive.Value))
        {
            if (!WinActive(this.edit_winTitle.text) && this.ChkShowOnActive.Value)
            {
                this.guiOverlay.Hide()
            }
            ; MsgBox(this.edit_winTitle.Text)
            ; this.Log("Found " this.edit_winTitle.Text "? " (WinActive(this.edit_winTitle.Text)), pre)
            if !WinExist(this.edit_winTitle.Text)
            {
                this.Log("Window Title: [" this.edit_winTitle.Text "] does not exist.", pre)
                return
            }

            language := (this.LANG_LIST[this.ddl_OCR.Value])

            ; 1000 ms delay to allow for OCR rate limiting
            if ((A_TickCount - this.StartTime) < 1000)
                return
            this.ocrResult := OCR.FromWindow(this.edit_winTitle.Text, {scale:2, lang:language})
            this.startTime := A_TickCount

            fuz := Fuzzy()

            val1 := Fuz.Match(this.oldOCRResult,this.ocrResult.text)

            WinGetPos(&winX, &winY, &winW, &winH, this.edit_winTitle.Value)

            ; if lower than threshold                OR   Window position changes  OR  Font Size Change  OR Font OPTIONS change
            if (val1 > this.OCR_SIMILARITY_THRESHOLD) && ((  (this.OldwinX = winX)
                                                          && (this.OldwinY = winY)
                                                          && (this.OldwinW = winW)
                                                          && (this.OldwinH = winH))
                                                                                    && (this.oldUpDown_FontSize = this.UpDown_FontSize.Value)
                                                                                    && (this.oldFontOptions     = this.ddl_fontOPtions.Text)
                &&    (this.Oldedit_colorTextBackground = this.edit_colorTextBackground.Value)
                &&    (this.Oldedit_colorTextFont = this.edit_colorTextFont.Value)
                )
                return

            this.Oldedit_colorTextBackground := this.edit_colorTextBackground.Value
            this.Oldedit_colorTextFont := this.edit_colorTextFont.Value

            this.oldUpDown_FontSize := this.UpDown_FontSize.Value
            this.oldFontOptions := this.ddl_fontOPtions.Text

            if (val1 <= this.OCR_SIMILARITY_THRESHOLD) || (this.OldwinX = winX)
                || (this.OldwinY = winY)
                || (this.OldwinW = winW)
                || (this.OldwinH = winH)
                this.OldOCRResult := this.ocrResult.Text

            this.OldwinX := winX
            this.OldwinY := winY
            this.OldwinW := winW
            this.OldwinH := winH



            tempOCRLines := []
            ; Iterate over each detected line
            for index, line in this.ocrResult.Lines
            {
                ; Get the line text
                text := line.Text

                ; remove any english characters from the line
                posttext := RegExReplace(text, "[a-zA-Z0-9]")

                ; if posttext only has punctuations, skip it. We'll check this by doing a string replace of all punctuations and checking if the length is 0. We have to be mindful of non-english characters.
                checkPostText := RegExReplace(postText, "[^\p{L}\p{N}]", "") ; remove all non-letters and non-numbers
        
                if (StrLen(checkPostText) = 0)
                    continue

                ; Or use the shortcut properties:
                x := line.x
                y := line.y
                w := line.w
                h := line.h

                ; MouseMove(x, y, 1)
                ; tempOCRLines.Push({text:text, x:x, y:y, w:w, h:h})
                tempOCRLines.Push({text:text, x:x, y:y, w:w, h:h})
                ; MsgBox("{text:" text "`n(" x "," y "," w "," h ")")
            }

            str_tempOCRLines := ""
            for k, v in tempOCRLines
            {
                str_tempOCRLines .= v.text "`n"
            }

            var_tlTo := this.ExtractFromSquareBracket(this.ddl_dest.Text)

            if !(Var_tlTo = (StrSplit(language,"-")[1])) {
                this.Log("Translating...")
                ; this.CursorWait
                tl_text := Translator.Translate(str_tempOCRLines, var_tlTo)

                ; this.guiOverlay.Cursor := "Wait"
            } else {
                this.Log("Same source and destination language.")
                tl_text := str_tempOCRLines
            }

            if !(tl_text)
                return

                ; this.CursorNormal
                ; this.guiOverlay.Cursor := "Normal"
                this.GenerateGUIOverlay()

                if (this.edit_colorTextFont.text = "")
                    this.edit_colorTextFont.text := "FFFF00"

                this.guiOverlay.setFont("c" this.edit_colorTextFont.text " s" this.UpDown_FontSize.Value, this.ddl_FontOptions.Text)
                for index, text in StrSplit(tl_text, "`n")
                {
                    if (!text)
                        continue

                    if (this.edit_colorTextBackground.Value = "")
                        this.edit_colorTextBackground.Value := "000000"
                    this.guiOverlay.Add("Text"
                        , "x" tempOCRLines[index].x " y" tempOCRLines[index].y " Background" this.edit_colorTextBackground.Value
                        , text
                    )
                }


            ; 4) Show full-screen and turn GREEN into per-pixel transparency
            this.guiOverlay.Opt("+LastFound +E0x20")
            WinSetTransColor(this.guiOverlay.BackColor, this.guiOverlay)

            WinGetPos(&winX, &winY, &winW, &winH, this.edit_winTitle.Text)

            this.winX := winX
            this.winY := winY
            this.winW := winW
            this.winH := winH

            this.guiOverlay.Show("x" this.winX " y" this.winY " w" this.winW " h" this.winH " NA")
        } else
            this.guiOverlay.hide
    }

    GenerateGuiOverlay(){
        ; If a GUI already exists, destroy it first
        try {
            this.guiOverlay.Destroy()
            this.guiOverlay := ""            ; clear the variable
        }

        this.Log("Generating Overlay")

        this.guiOverlay := Gui()
        this.guiOverlay.opt("+AlwaysOnTop +ToolWindow -Caption")
        ; this.guiOverlay.Opt(" +E0x80000")
        ; this.guiOverlay.Color := "0x202020"           ; fill it GREEN (we’ll key this out)
        this.guiOverlay.BackColor := "0xEEAA99"           ; The color to make transparent)
    }

    ; CursorWait() {
    ;     DllCall("SetCursor", "ptr", DllCall("LoadCursor", "ptr", 0, "str", "IDC_WAIT", "ptr"))

    ; }

    ; CursorNormal() {
    ;     DllCall("SetCursor", "ptr", DllCall("LoadCursor", "ptr", 0, "str", "IDC_ARROW", "ptr"))

    ; }

    HideGuiOverlay() {
        this.guiOverlay.Hide()
    }

    StartOCR(callback, info) {
        pre := "[OCR] "
        this.Log("Starting OCR", pre)
        this.btn_start.Enabled := False
        this.btn_stop.Enabled := True
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
            ; RegExMatch(this.gListSrc[this.ddl_src.Value], "^.*?\[(.*?)\]", &matchSrc)
            reg_ddl_src := this.ExtractFromSquareBracket(this.ddl_src.Text)
            this.Log("Google Source Selection: " this.ddl_src.Text, pre)

        if (this.ddl_dest.Value)
            reg_ddl_dest := this.ExtractFromSquareBracket(this.ddl_dest.Text)
            ; RegExMatch(this.gListDest[this.ddl_dest.Text], "^.*?\[(.*?)\]", &matchDest)

            this.Log("Google Destination Selection: " this.ddl_dest.Text, pre)


        ; this.Log(
        ;     "this.ddl_OCR.Value:  " this.LANG_LIST[this.ddl_OCR.Value] "`n"
        ;     "this.ddl_src.Value:  " (this.ddl_src.Value ? reg_ddl_src : 0) "`n"
        ;     "this.ddl_dest.Value: " (this.ddl_dest.Value ? reg_ddl_dest : 0) "`n"
        ;     "this.ddl_dest.Value: " this.edit_winTitle.Value "`n"
        ; , pre)
        ; disable fields

        ; retrievew variables
        ; start OCR

        this.objReadScreen := ObjBindMethod(this, "ReadScreen").Bind(1,1)
        SetTimer(this.objReadScreen, 50)
    }


    EndOCR(callback, info) {
        this.Log("OCR Stopped!")
        SetTimer(this.ObjReadScreen, 0)
        this.HideGuiOverlay

        this.btn_START.Enabled := True
        this.btn_Stop.Enabled := False
        this.edit_winTitle.Enabled := True
        ; Enable Fields
        ; stop OCR
    }

    FindWindowName(callback, info) {
        this.edit_winTitle.Enabled := False
        this.timer_DetectWindowName := ObjBindMethod(this, "DetectWindowName")
        SetTimer(this.timer_DetectWindowName, 80)
        this.Log("Finding Window...")
    }

    DetectWindowName() {
        MouseGetPos(&outDetectWinX, &outDetectWinY,&outDetectWinWinID)

        if  (this.OldoutDetectWinX  = outDetectWinX )
        &&  (this.OldoutDetectWinY = outDetectWinY)
        &&  (this.OldoutDetectWinWinID = outDetectWinWinID)
        &&  !(GetKeyState("LCtrl","P"))
        &&  !(GetKeyState("RCtrl","P"))
        &&  !(GetKeyState("Esc","P"))
            return

        this.OldoutDetectWinX  := outDetectWinX
        this.OldoutDetectWinY := outDetectWinY
        this.OldoutDetectWinWinID := outDetectWinWinID

        winT := WinGetTitle("ahk_id" outDetectWinWinID)
        winP := WinGetProcessName("ahk_id" outDetectWinWinID)

        tempWinFull := winT " ahk_exe " winP
        tempWinTitle := winT
        tempWinEXE := "ahk_exe " winP


        str := Format("
        (
            Window Title:
            --------------------------------------------
            {1}
            --------------------------------------------
            Press [Ctrl] to save and update your GUI.
            Press [Esc] to cancel.
            )",
            (this.radiofull.value ? tempWinFull : (this.RadioWinT.Value ? tempWinTitle : tempWinEXE))
        )

        ToolTip(str, outDetectWinX - 150, outDetectWinY + 40)

        if GetKeyState("LCtrl", "P") || GetKeyState("RCtrl", "P")
        {
            SetTimer(this.timer_DetectWindowName, 0)
            ToolTip()

            if (this.RadioFull.Value)
                this.edit_winTitle.Value := winT " ahk_exe " winP
            else if (this.RadioWinT.Value)
                this.edit_winTitle.Value := winT
            else if (this.RadioEXE.Value)
                this.edit_winTitle.Value := "ahk_exe " winP


            ; this.edit_winTitle.Value := winT " ahk_exe " winP
            this.edit_winTitle.Enabled := True
            this.Log("Finding Window: Window Saved to Edit box!")
        } else if (GetKeyState("Esc", "P"))
        {
            SetTimer(this.timer_DetectWindowName, 0)
            ToolTip()
            this.edit_winTitle.Enabled := True
            this.Log("Finding Window: Cancelled")
        }
}

    Log(str, prefix := "") {
        time := "[" A_Hour ":" A_Min ":" A_Sec "]: "
        this.guiSB.SetText(time . prefix . str)
    }

    OnGuiClose(*) {

        WinGetPos(&MainGuiX, &MainGuiY, &MainGuiW, &MainGuiH, "ahk_id" this.guiStartUP.hwnd)

        this.MainGuiX := MainGuiX
        this.MainGuiY := MainGuiY
        this.MainGuiW := MainGuiW
        this.MainGuiH := MainGuiH

        this.SaveConfigs(1,1)
        ; this.CursorNormal
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

    LimitToHex(ctrl) {
        this.Log("Changing colors: " ctrl.Text)
        text := ctrl.Text
        newText := ""
        for char in StrSplit(text)
        {
            if ( (Ord(char) >= 48 && Ord(char) <= 57)   ; 0-9
              || (Ord(char) >= 65 && Ord(char) <= 70)    ; A-F
              || (Ord(char) >= 97 && Ord(char) <= 102) ) ; a-f
            {
                newText .= char
            }
        }
        if (newText != text)
        {
            if !(StrLen(newText) = 0)
                ctrl.Text := newText
            else
                ctrl.Text := "000000"
        }

        this.SaveConfigs(1,1)
    }

    SaveConfigs(callback, info) {
        pre := "[SAVE] "
        this.Log("Saving Configs", pre)
        this.guiStartUP.Submit(0)

        try {
            IniWrite(Trim(this.ddl_OCR.Text),  this.config_fileName, "OCR", "UWP")
            IniWrite(Trim(this.ddl_src.Text),  this.config_fileName, "OCR", "gTL_FROM")
            IniWrite(Trim(this.ddl_dest.Text), this.config_fileName, "OCR", "gTL_TO")

            IniWrite(Trim(this.chkNotes.Value), this.config_fileName, "Settings","ShowNotes")
            IniWrite(Trim(this.edit_winTitle.Value), this.config_fileName, "Settings", "TargetWindow")
            ; this.OCR_SIMILARITY_THRESHOLD := IniRead(this.config_fileName, "Settings","OCR_SIMILARITY_THRESHOLD", 80)

            IniWrite(Trim(this.OCR_SIMILARITY_THRESHOLD), this.config_fileName,"Settings", "OCR_SIMILARITY_THRESHOLD")
            IniWrite(Trim(this.ChkShowOnActive.Value),this.config_fileName,"Settings","varShowOnActive")

            IniWrite(this.MainGuiX, this.config_fileName, "GUI","MainGuiX")
            IniWrite(this.MainGuiY, this.config_fileName, "GUI","MainGuiY")

            IniWrite(this.ddl_FontOptions.Text, this.config_fileName, "GUI", "Font")

            if (StrLen(This.edit_colorTextFont.Value) = 6)
                IniWrite((this.edit_colorTextFont.Value), this.config_fileName, "GUI", "FontColor")
            if (StrLen(This.edit_colorTextBackground.Value) = 6)
                IniWrite((this.edit_colorTextBackground.Value), this.config_fileName, "GUI", "FontBackground")
            IniWrite(this.UpDown_FontSize.Value,this.config_fileName,"GUI","UpDownFontSize")

            IniWrite(this.RadioFull.Value, this.config_fileName, "GUI", "RadioFull")
            IniWrite(this.RadioWinT.Value, this.config_fileName, "GUI", "RadioWinT")
            IniWrite(this.RadioEXE.Value,  this.config_fileName, "GUI", "RadioEXE")
            ; MsgBox(this.OCR_SIMILARITY_THRESHOLD)

 

            this.Log("Configs saved", pre)
        }
        catch as e {
            this.Log("Saving Error: " e.What A_Tab e.Message, pre)
            ; MsgBox("Saving Error: [" e.line "]" e.What A_Tab e.Message)
        }
    }

    LoadConfigs(callback, info) {
        pre := "[LOAD] "
        ; auto-select default configurations
        this.Log("Loading configs", pre)

        try {

            var_OCR   := IniRead(this.config_fileName, "OCR","UWP", "en-US")
            this.Log("Saved OCR Language: " var_OCR, pre)

            this.Log("Loading OCR Language: " var_OCR, pre)
            this.ddl_OCR.choose(var_OCR)
        } catch {
            this.Log("Failed to load OCR Language: " var_OCR ". Choosing first available language.", pre)
            this.ddl_OCR.choose(1)
        }

        try
        {
            var_gSrc  := IniRead(this.config_fileName, "OCR","gTL_FROM", "Auto Detect [auto]")
            this.Log("Saved Language to translate from: " var_gSrc, pre)

            this.Log("Loading [TL FROM] drop down list: " var_gSrc, pre)
            this.ddl_src.choose(var_gSrc)
        } catch {
            this.Log("Failed to load SOURCE language. Setting as 'Auto Detect'", pre)
            this.ddl_src.choose(1)
        }

        try
        {
            var_gDest := IniRead(this.config_fileName, "OCR","gTL_TO", "en")
            this.Log("Saved Language to translate from: " var_gDest, pre)

            this.Log("Attempting to choose on [TL TO] drop down list: " var_gDest, pre)
            this.ddl_dest.choose(var_gDest)
        } catch {
            this.Log("Failed to load DESTINATION language. Setting as first available language.", pre)
            this.ddl_dest.choose(1)
        }

        try
        {
            var_CheckNotes    := IniRead(this.config_fileName, "Settings","ShowNotes", 1)
            this.var_ShowNotes := var_checkNotes

            var_TargetWindows := IniRead(this.config_fileName, "Settings", "TargetWindow", "A")
            this.edit_winTitle.Value := var_TargetWindows

            var_ShowOnActive := IniRead(this.config_fileName, "Settings","varShowOnActive",1)
            this.chkShowOnActive.Value := var_ShowOnActive

            this.MainGuiX := IniRead(this.config_fileName,"GUI","MainGuiX",0)
            this.MainGuiY := IniRead(this.config_fileName,"GUI","MainGuiY",0)

            this.ddl_FontOptions.Text := IniRead(this.config_fileName, "GUI", "Font", "Arial")
            this.edit_colorTextFont.Value := IniRead(this.config_fileName, "GUI", "FontColor", "FFFF00")
            this.edit_colorTextBackground.Value := IniRead(this.config_fileName, "GUI", "FontBackground", "000000")
            this.UpDown_FontSize.Value := IniRead(this.config_fileName,"GUI", "UpDownFontSize", 14)

            this.RadioFull.Value := IniRead(this.config_fileName, "GUI", "RadioFull", 1)
            this.RadioWinT.Value := IniRead(this.config_fileName, "GUI", "RadioWinT",0)
            this.RadioEXE.Value  := IniRead(this.config_fileName, "GUI", "RadioEXE",0)

        
       }
        catch as e {
            MsgBox("Loading Error " e.what " [" e.Line "]: " e.Message)
        }
    }

    Initialize() {
        this.Log("Initializing")

            this.var_ShowNotes := IniRead(this.config_fileName, "Settings","ShowNotes", 1)
            this.Gui_WIDTH := 300
            this.Gui_CTRL_WIDTH := this.GUI_WIDTH - 20
            this.MainGuiX := IniRead(this.config_fileName,"GUI","MainGuiX",0)
            this.MainGuiY := IniRead(this.config_fileName,"GUI","MainGuiY",0)

            this.OCR_SIMILARITY_THRESHOLD := IniRead(this.config_fileName, "Settings","OCR_SIMILARITY_THRESHOLD", "0.80")

            ; MsgBox(this.OCR_SIMILARITY_THRESHOLD)
            this.guiOverlay := Gui()
    }

    GenerateList() {
        this.Log("Generating lists")
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
        this.Log("Refreshing drop down lists")
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
        this.Log("Removing Language" this.OCR_Available_DL_Languages.Text)
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
        this.Log("Downloading language: " this.OCR_Available_DL_Languages.Text)
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
        ; extracts the text between the first set of ~~~ and ~

        try this.ddl_OCR.Text := StrSplit(language_abbrev,"-")[1]
        ; this.ddl_OCR.Value := this.OCR_Available_DL_Languages.Text
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
        this.Log("Opened the Language & Region Settings on Window")
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
            TLDR:
            (1): OCR retrieves text from the screen`n(2): Google Translates Text from (1)`n(3): AHK builds Overlay

            PHASE 1: OCR - TEXT EXTRACTION with UWP
            To minimize installations of outside programs, this script taps into an OCR engine present in the Universal Windows Platform (UWP) API, specifically, the "Windows.Media.OCR" namespace.
            This is only available in Windows 10 and above.
            To be able to extract the text, the appropriate language MUST be installed on your computer.
            PHASE 2: TRANSLATING - with Google Translate API
            The text is then sent to the Google Translate API for translation.
            The API is free to use, but you must have an internet connection.
            Some limitations: I think the API is limited to 5000 characters per request, and 100 requests per 100 seconds.
            With the text retrieved from the OCR engine, the words are all joined together for one massive translation.
            Translation is done through the Google Translate API.
            PHASE 3: DISPLAY - with AHK GUI
            The translated text is then displayed on the screen, in the same position as the original text.
            The UWP OCR stores the positions of the lines it decoded. AHK now uses those position, along with the newly translated lines, to draw the on screen.
            The drawing is done via an AHK GUI. The background is set to be transparent, and only the Texts are drawn, respective to their word locations.
            Note:
            For the text overlay to update, the words on screen must change or the window must change position!
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
                ; MsgBox(exec.StdOut.ReadAll())
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

    FontOptions() {
        optionsFont := "
        (
            Aharoni
            Aldhabi
            Andalus
            Angsana New
            AngsanaUPC
            Aparajita
            Arabic Typesetting
            Arial
            Arial Black
            Arial Nova
            Bahnschrift
            Batang
            BatangChe
            BIZ UDGothic
            BIZ UDMincho Medium
            BIZ UDPGothic
            Browallia New
            BrowalliaUPC
            Calibri
            Calibri Light
            Cambria
            Cambria Math
            Candara
            Cascadia Code
            Cascadia Mono
            Comic Sans MS
            Consolas
            Constantia
            Corbel
            Cordia New
            CordiaUPC
            Courier
            Courier New
            DaunPenh
            David
            DengXian
            DFKai-SB
            DilleniaUPC
            DokChampa
            Dotum
            DotumChe
            Ebrima
            Estrangelo Edessa
            EucrosiaUPC
            Euphemia
            FangSong
            Fixedsys
            Franklin Gothic Medium
            FrankRuehl
            FreesiaUPC
            Gabriola
            Gadugi
            Gautami
            Georgia
            Georgia Pro
            Gill Sans Nova
            Gisha
            Gulim
            GulimChe
            Gungsuh
            GungsuhChe
            HoloLens MDL2 Assets
            Impact
            Ink Free
            IrisUPC
            Iskoola Pota
            JasmineUPC
            Javanese Text
            KaiTi
            Kalinga
            Kartika
            Khmer UI
            KodchiangUPC
            Kokila
            Lao UI
            Latha
            Leelawadee
            Leelawadee UI
            Levenim MT
            LilyUPC
            Lucida Console
            Lucida Sans
            Lucida Sans Unicode
            Malgun Gothic
            Mangal
            Marlett
            Meiryo
            Meiryo UI
            Microsoft Himalaya
            Microsoft JhengHei
            Microsoft JhengHei UI
            Microsoft New Tai Lue
            Microsoft PhagsPa
            Microsoft Sans Serif
            Microsoft Tai Le
            Microsoft Uighur
            Microsoft YaHei
            Microsoft YaHei UI
            Microsoft Yi Baiti
            MingLiU
            MingLiU_HKSCS
            MingLiU_HKSCS-ExtB
            MingLiU-ExtB
            Miriam
            Miriam Fixed
            Modern
            Mongolian Baiti
            MoolBoran
            MS Gothic
            MS Mincho
            MS PGothic
            MS PMincho
            MS Serif
            MS Sans Serif
            MS UI Gothic
            MV Boli
            Myanmar Text
            Narkisim
            Neue Haas Grotesk Text Pro
            Nirmala UI
            NSimSun
            Nyala
            Palatino Linotype
            Plantagenet Cherokee
            PMingLiU
            PMingLiU-ExtB
            Raavi
            Rockwell Nova
            Rod
            Roman
            Sakkal Majalla
            Sanskrit Text
            Script
            Segoe Fluent Icons
            Segoe MDL2 Assets
            Segoe Print
            Segoe Script
            Segoe UI
            Segoe UI Emoji
            Segoe UI Historic
            Segoe UI Variable
            Segoe UI Symbol
            Shonar Bangla
            Shruti
            SimHei
            Simplified Arabic
            Simplified Arabic Fixed
            SimSun
            SimSun-ExtB
            Sitka Banner
            Sitka Display
            Sitka Heading
            Sitka Small
            Sitka Subheading
            Sitka Text
            Small Fonts
            Sylfaen
            Symbol
            System
            Tahoma
            Terminal
            Times New Roman
            Traditional Arabic
            Trebuchet MS
            Tunga
            UD Digi Kyokasho N-B
            UD Digi Kyokasho NK-B
            UD Digi Kyokasho NK-R
            UD Digi Kyokasho NP-B
            UD Digi Kyokasho NP-R
            UD Digi Kyokasho N-R
            Urdu Typesetting
            Utsaah
            Vani
            Verdana
            Verdana Pro
            Vijaya
            Vrinda
            Webdings
            Wingdings
            Yu Gothic
            Yu Gothic UI
            Yu Mincho
        )"
        return StrSplit(optionsFont, "`n")
    }
}


; *F8::Reload


; *F12::ExitApp
