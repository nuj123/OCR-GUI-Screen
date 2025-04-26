; _ErrorException := OnError(LogError, 1)


pr(str := "") {
    static p
    p := debug()
    p.print(str, 1, 1)
    return str
}

try {
    print(str := "") {
        pr(str)
    }

}
LogError(exception, mode) {
    pr((mode = 1) ? "THROWN ERROR" : "Return/Exit/ExitApp")
    pr("Error: ")
    if (exception.message)
        pr("Message: " exception.message)
    if (exception.What)
        pr("What: " exception.What)
    if (exception.Extra)
        pr("Extra: " exception.Extra)
    if (exception.File)
        pr("File: " exception.File)
    if (exception.Line)
        pr("Line: " exception.Line)
    if (exception.Stack)
        pr("Stack: " exception.Stack)
    return True
}

class debug {

    ; creates a way to output the info.
    print(str := "", toStdOut := 1, enablePadding := 1)
    {
        /*
            toStdOut: 
                0 = OutputDebug
                1 = StdOut: FileAppend, str, *
                2 = StdErr: FileAppend, str, **
        */

        this.enablePadding := enablePadding

        if IsObject(str) {
            str :=  this.toString(str)
        }

        str .= "`n"

        if (toStdOut = 0)             ; outputDebug
            OutputDebug(str)

        else if (toStdOut = 1)        ; stdOut
            FileAppend(str, "*")

        else if (toStdOut = 2)        ; stdErr
            FileAppend(str, "**")

        else
            FileAppend(str, "*")

    }

    toString(obj) {
        if !IsObject(obj) {
            return obj . "`n"
        } else {
            return this.ExploreObject(obj) . "`n"
        }
    }

    exploreObject(arr, padding := 1, fullpath := "") {

        for k, v in arr
        {
            tempPath := fullPath

            ; adds a dot between each key
            if (tempPath) {
                tempPath .= "."
            }

            pads := (this.EnablePadding ? this.padSpace(padding) : "")

            tempPath .= k

            str .= pads . "[" tempPath "]: "

            if !(IsObject(v))
                str .= v "`n"
            else
                str .= "`n" this.exploreObject(v, padding + 1, tempPath)
        }

        return str
    }

    ; adds indentation for the different array levels
    padSpace(x := 1, spacing := " ", preSpace := "", postSpace := "") {
        indent_space := 4

        if (StrLen(spacing) < 1)
            spacing := " "
        else
            spacing := SubStr(spacing, 1, 1)

        str := preSpace . ""
        Loop(x * indent_space)
        {
            str .= spacing
        }
        return  str . postSpace
    }
}