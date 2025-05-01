#Requires AutoHotkey v2
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir

class ScreenTL {
    config_fileName := A_ScriptDir "/SCREEN_OCR_config.ini"
    guiStartUP := Gui()
    guiOverlay := Gui()
    LANG_LIST := []
    gListSrc := []
    gListDest := []

    __New() {
        this.Initialize()
        this.SetupGui()
        this.LoadConfigs()
        this.guiStartUP.Show("x" this.MainGuiX " y" this.MainGuiY)
        this.guiStartUP.OnEvent("Close", ObjBindMethod(this, "OnGuiClose"))
    }

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

    AddText(label, options := "", align := "") {
        this.guiStartUP.Add("Text", options " " align, label)
    }

    AddButton(label, options := "", callback := "") {
        btn := this.guiStartUP.Add("Button", options, label)
        if callback
            btn.OnEvent("Click", callback)
        return btn
    }

    AddDropDown(label, items, callback := "") {
        this.AddText(label)
        ddl := this.guiStartUP.Add("DDL", "w" this.Gui_CTRL_WIDTH, items)
        if callback
            ddl.OnEvent("Change", callback)
        return ddl
    }

    Log(message, prefix := "") {
        time := "[" A_Hour ":" A_Min ":" A_Sec "]: "
        this.guiSB.SetText(time . prefix . message)
    }

    ReadConfig(section, key, default := "") {
        return IniRead(this.config_fileName, section, key, default)
    }

    WriteConfig(section, key, value) {
        IniWrite(value, this.config_fileName, section, key)
    }

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

    LoadConfigs() {
        this.Log("Loading configs", "[LOAD] ")
        this.ddl_OCR.Text := this.ReadConfig("OCR", "UWP", "en-US")
        this.ddl_src.Text := this.ReadConfig("OCR", "gTL_FROM", "Auto Detect [auto]")
        this.ddl_dest.Text := this.ReadConfig("OCR", "gTL_TO", "en")
        this.var_ShowNotes := this.ReadConfig("Settings", "ShowNotes", 1)
        this.MainGuiX := this.ReadConfig("GUI", "MainGuiX", 0)
        this.MainGuiY := this.ReadConfig("GUI", "MainGuiY", 0)
    }

    GenerateLanguageLists() {
        this.LANG_LIST := this.ListOfInstalledLanguages()
        this.gListSrc := this.GoogleLanguageList()
        this.gListSrc.InsertAt(1, "Auto Detect [auto]")
        this.gListDest := this.gListSrc.Clone()
    }

    ListOfInstalledLanguages() {
        return OCR.GetAvailableLanguages()
    }

    GoogleLanguageList() {
        return [
            ["English_United_States", "0409", "en"],
            ["French_Standard", "040c", "fr"],
            ["Spanish_Traditional_Sort", "040a", "es"]
        ]
    }

    StartOCR() {
        this.Log("Starting OCR", "[OCR] ")
        ; Add OCR start logic here
    }

    EndOCR() {
        this.Log("Stopping OCR", "[OCR] ")
        ; Add OCR stop logic here
    }

    OnGuiClose() {
        this.SaveConfigs()
        ExitApp
    }
}
