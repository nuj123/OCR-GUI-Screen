# QuickTranslate  
*(A very imperfect but very handy script)*

## What this script does  
This script lets you select a window, grab whatever text is on it (even if you can't normally copy it), translate that text into another language, and pop the translation up on your screen.  
It's super useful for things like untranslated games, random apps, or websites stuck in another language.

## How it does it  
- **OCR**: It uses the Microsoft UWP OCR engine to "read" the text from the window like a pair of robot eyes.  
- **Translation**: Then it sends the text to Google Translate's API to get it into your language of choice.  
- **Display**: Finally, it slaps the translated text onto a little AHK-made GUI that floats over your screen.  
  (Fair warning: the GUI is kinda ugly because I have questionable taste in colors.)

The whole thing is written in **AutoHotkey v2** — so it's lightweight and pretty fast.

## Using PowerShell for OCR Languages  
If you need to install or manage OCR languages, you'll have to mess around with PowerShell. 
Although it's already added in the script, here's the cheat sheet:

- **List all available OCR languages (requires admin rights)**:
    ```powershell
    Get-WindowsCapability -Online | Where-Object { $_.Name -like 'Language.OCR*' } | Select-Object -ExpandProperty Name
    ```
- **Download a new OCR language (requires admin rights)**:
    ```powershell
    Add-WindowsCapability -Online -Name "{LANGUAGE_VARIABLE}"
    ```
- **Remove an OCR language (requires admin rights)**:
    ```powershell
    Remove-WindowsCapability -Online -Name "{LANGUAGE_VARIABLE}"
    ```

> Note: `{LANGUAGE_VARIABLE}` will look something like `Language.OCR.Jpn~~~~0.0.1.0` for Japanese OCR.

## FAQ

**Q: Why does the overlay look like a 2003 PowerPoint template?**  
A: I made some bad life choices with the color picker. I'm working on it... maybe.

**Q: This GUI sucks. The color choices are terrible.**
A: Firstly, that wasn't a question. Secondly, my main objective was to separate the sections by text color, and my color choices are wonderful. Wonderfully bad.

**Q: Does this work on any window?**  
A: Mostly, yes! It grabs text from anything that's visible. But if the window is super weird (like some 3D games), it might struggle. Open up your favorite raw Manga/Manwha, and read away. 

**Q: Is my data safe?**  
A: The script only sends the grabbed text to Google's translation service. It doesn’t save anything, log anything, or do anything shady. Or at least it's not suppose to. If it is, report it, for sure.

**Q: Can I change the language?**  
A: Yep! You just edit a line in the script to pick your target language.

**Q: Why AutoHotkey v2?**  
A: Because it's newer, cleaner, and I'm pretending I'm a responsible coder.
