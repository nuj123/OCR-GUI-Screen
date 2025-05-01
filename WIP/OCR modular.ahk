#Requires AutoHotkey v2
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir

; Define the ScreenTL class which handles the GUI, configuration, and OCR functionality
class ScreenTL {
    ; Define class variables for configuration, GUI elements, and language lists
    config_fileName := A_ScriptDir "/SCREEN_OCR_config.ini"
    guiStartUP := Gui()
    guiOverlay := Gui()
    LANG_LIST := []
    gListSrc := []
    gListDest := []

    ; Constructor: Initialize the class, set up the GUI, load configurations, and show the main GUI
    __New() {
        this.Initialize()
        this.SetupGui()
        this.LoadConfigs()
        this.guiStartUP.Show("x" this.MainGuiX " y" this.MainGuiY)
        this.guiStartUP.OnEvent("Close", ObjBindMethod(this, "OnGuiClose"))
    }

    ; Initialize variables, read configurations, and generate language lists
    Initialize() {
        this.Log("Initializing")
        this.var_ShowNotes := this.ReadConfig("Settings", "ShowNotes", 1)
        this.Gui_WIDTH := 300
        this.Gui_CTRL_WIDTH := this.Gui_WIDTH - 20
        this.MainGuiX := this.ReadConfig("GUI", "MainGuiX", 0)
        this.MainGuiY := this.ReadConfig("GUI", "MainGuiY", 0)
        this.OCR_SIMILARITY_THRESHOLD := this.ReadConfig("Settings", "OCR_SIMILARITY_THRESHOLD", "0.80")
        this.GenerateLanguageLists()
    }

    ; Set up the main GUI with buttons, dropdowns, and other controls
    SetupGui() {
        this.guiStartUP.BackColor := 0x202020
        this.guiStartUP.Opt("+DPIScale")
        this.guiSB := this.guiStartUP.Add("StatusBar",, "Hi")
        this.AddText("Description", "w" this.Gui_CTRL_WIDTH, "center")
        this.AddButton("START Screen Translation", "w" this.Gui_CTRL_WIDTH, ObjBindMethod(this, "StartOCR"))
        this.AddButton("STOP Screen Translation", "w" this.Gui_CTRL_WIDTH, ObjBindMethod(this, "EndOCR"))
        this.AddDropDown("OCR Language", this.LANG_LIST, ObjBindMethod(this, "SaveConfigs"))
        this.AddDropDown("Google Translate Source", this.gListSrc, ObjBindMethod(this, "SaveConfigs"))
        this.AddDropDown("Google Translate Destination", this.gListDest, ObjBindMethod(this, "SaveConfigs"))
    }

    ; Helper function to add a text label to the GUI
    AddText(label, options := "", align := "") {
        this.guiStartUP.Add("Text", options " " align, label)
    }

    ; Helper function to add a button to the GUI and bind a callback function
    AddButton(label, options := "", callback := "") {
        btn := this.guiStartUP.Add("Button", options, label)
        if callback
            btn.OnEvent("Click", callback)
        return btn
    }

    ; Helper function to add a dropdown list to the GUI and bind a callback function
    AddDropDown(label, items, callback := "") {
        this.AddText(label)
        ddl := this.guiStartUP.Add("DDL", "w" this.Gui_CTRL_WIDTH, items)
        if callback
            ddl.OnEvent("Change", callback)
        return ddl
    }

    ; Log messages to the status bar with an optional prefix
    Log(message, prefix := "") {
        time := "[" A_Hour ":" A_Min ":" A_Sec "]: "
        this.guiSB.SetText(time . prefix . message)
    }

    ; Read a value from the configuration file
    ReadConfig(section, key, default := "") {
        return IniRead(this.config_fileName, section, key, default)
    }

    ; Write a value to the configuration file
    WriteConfig(section, key, value) {
        IniWrite(value, this.config_fileName, section, key)
    }

    ; Save the current configurations to the configuration file
    SaveConfigs() {
        this.Log("Saving Configs", "[SAVE] ")
        this.WriteConfig("OCR", "UWP", this.ddl_OCR.Text)
        this.WriteConfig("OCR", "gTL_FROM", this.ddl_src.Text)
        this.WriteConfig("OCR", "gTL_TO", this.ddl_dest.Text)
        this.WriteConfig("Settings", "ShowNotes", this.var_ShowNotes)
        this.WriteConfig("Settings", "TargetWindow", this.edit_winTitle.Value)
        this.WriteConfig("Settings", "OCR_SIMILARITY_THRESHOLD", this.OCR_SIMILARITY_THRESHOLD)
        this.WriteConfig("GUI", "MainGuiX", this.MainGuiX)
        this.WriteConfig("GUI", "MainGuiY", this.MainGuiY)
    }

    ; Load configurations from the configuration file
    LoadConfigs() {
        this.Log("Loading configs", "[LOAD] ")
        this.ddl_OCR.Text := this.ReadConfig("OCR", "UWP", "en-US")
        this.ddl_src.Text := this.ReadConfig("OCR", "gTL_FROM", "Auto Detect [auto]")
        this.ddl_dest.Text := this.ReadConfig("OCR", "gTL_TO", "en")
        this.var_ShowNotes := this.ReadConfig("Settings", "ShowNotes", 1)
        this.MainGuiX := this.ReadConfig("GUI", "MainGuiX", 0)
        this.MainGuiY := this.ReadConfig("GUI", "MainGuiY", 0)
    }

    ; Generate lists of available languages for OCR and Google Translate
    GenerateLanguageLists() {
        this.LANG_LIST := this.ListOfInstalledLanguages()
        this.gListSrc := this.GoogleLanguageList()
        this.gListSrc.InsertAt(1, "Auto Detect [auto]")
        this.gListDest := this.gListSrc.Clone()
    }

    ; Retrieve the list of installed OCR languages
    ListOfInstalledLanguages() {
        return OCR.GetAvailableLanguages()
    }

    ; Define a list of supported Google Translate languages
    GoogleLanguageList() {
        return [
            ["English_United_States", "0409", "en"],
            ["French_Standard", "040c", "fr"],
            ["Spanish_Traditional_Sort", "040a", "es"]
        ]
    }

    ; Start the OCR process (logic to be implemented)
    StartOCR() {
        this.Log("Starting OCR", "[OCR] ")
        ; Add OCR start logic here
    }

    ; Stop the OCR process (logic to be implemented)
    EndOCR() {
        this.Log("Stopping OCR", "[OCR] ")
        ; Add OCR stop logic here
    }

    ; Handle the GUI close event by saving configurations and exiting the app
    OnGuiClose() {
        this.SaveConfigs()
        ExitApp
    }
}

; TODO:
; 1. Implement the logic for the StartOCR() method to initiate OCR functionality.
; 2. Implement the logic for the EndOCR() method to stop OCR functionality.
; 3. Add error handling for reading/writing configuration files.
; 4. Validate the dropdown selections before saving configurations.
; 5. Enhance the GUI with additional controls or features if needed.
; 6. Test the application thoroughly to ensure all features work as expected.
; 7. Add support for dynamically updating the language lists if needed.
; 8. Optimize the performance of the OCR process and GUI responsiveness.
