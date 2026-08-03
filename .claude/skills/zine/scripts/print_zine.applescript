-- Triggers PagePacker's native Print dialog on the currently open document.
-- This is the last automatable step: PagePacker's AppleScript `print`
-- command ignores any settings/output-path passed to it (confirmed by
-- reading MyDocument.m), so there is no way to script a flattened PDF
-- export -- the user must choose PDF > "Save as PDF..." in the dialog
-- this opens.
--
-- IMPORTANT: this assumes the assembled document is still open from
-- assemble_zine.applescript (which does not close it) -- do not close
-- PagePacker between assembling and printing. Re-opening a saved .pp file
-- via AppleScript's `open` command was found to silently fail (confirmed
-- during development: the app accepts the open request but no document
-- appears) -- there is no reliable scripted fallback for this case. If the
-- document was closed, ask the user to reopen it themselves from within
-- PagePacker (File > Open) before retrying this script.
--
-- Usage: osascript print_zine.applescript

on run argv
    tell application "PagePacker"
        activate
        print document 1 print dialog true
    end tell
end run
