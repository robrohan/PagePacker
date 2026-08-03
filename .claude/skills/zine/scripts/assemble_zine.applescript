-- Drives PagePacker to assemble a zine: creates a new document, drops each
-- of the 8 generated panel PDFs onto its corresponding page (in final
-- reading order -- see reference/layout_notes.md), and saves the native
-- .pp document. Prints the window's CGWindowID on success, for use with
-- `screencapture -l <id>` to self-verify the result (file source is
-- write-only with no readback -- see reference/layout_notes.md).
--
-- Usage: osascript assemble_zine.applescript panel1.pdf ... panel8.pdf output.pp

on run argv
    if (count of argv) is not 9 then
        error "Usage: assemble_zine.applescript <8 panel pdfs> <output.pp>"
    end if

    set panelPaths to items 1 thru 8 of argv
    set outputPath to item 9 of argv

    tell application "PagePacker"
        activate
        set targetDoc to make new document

        repeat with i from 1 to 8
            set thisPath to item i of panelPaths
            tell targetDoc
                tell page i
                    set file source to POSIX file thisPath
                end tell
            end tell
        end repeat

        save targetDoc in POSIX file outputPath

        return (id of window 1) as text
    end tell
end run
