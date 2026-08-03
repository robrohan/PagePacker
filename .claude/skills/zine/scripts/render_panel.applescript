-- Renders one zine panel (a heading + body text) to a single-page PDF,
-- sized to exactly match a PagePacker page panel. Uses the same
-- draw-a-view-to-PDF technique PagePacker's own PDFUtility.m uses
-- internally (NSView dataWithPDFInsideRect:) -- no browser, no external app.
--
-- Usage: osascript render_panel.applescript <heading> <body> <outputPath> [width] [height]
--   width/height are optional, in points, default to 306x198 (Letter panel).

use framework "Foundation"
use framework "AppKit"
use scripting additions

on run argv
    if (count of argv) < 3 then
        error "Usage: render_panel.applescript <heading> <body> <outputPath> [width] [height]"
    end if

    set headingText to item 1 of argv as text
    set bodyText to item 2 of argv as text
    set outPath to item 3 of argv as text

    set pageW to 306.0
    set pageH to 198.0
    if (count of argv) >= 5 then
        set pageW to (item 4 of argv) as real
        set pageH to (item 5 of argv) as real
    end if

    set insetX to 14.0
    set insetY to 12.0

    set theFrame to current application's NSMakeRect(0, 0, pageW, pageH)
    set theView to current application's NSTextView's alloc()'s initWithFrame:theFrame

    theView's setDrawsBackground:true
    theView's setBackgroundColor:(current application's NSColor's whiteColor())
    theView's setTextContainerInset:(current application's NSMakeSize(insetX, insetY))

    -- Paragraph style: a little breathing room between heading and body, and between lines
    set headingParaStyle to current application's NSMutableParagraphStyle's alloc()'s init()
    headingParaStyle's setParagraphSpacing:6.0

    set bodyParaStyle to current application's NSMutableParagraphStyle's alloc()'s init()
    bodyParaStyle's setLineSpacing:2.0
    bodyParaStyle's setParagraphSpacing:4.0

    set headingFont to current application's NSFont's boldSystemFontOfSize:15.0
    set bodyFont to current application's NSFont's systemFontOfSize:9.5

    set headingAttrs to current application's NSMutableDictionary's dictionary()
    (headingAttrs's setObject:headingFont forKey:(current application's NSFontAttributeName))
    (headingAttrs's setObject:headingParaStyle forKey:(current application's NSParagraphStyleAttributeName))

    set bodyAttrs to current application's NSMutableDictionary's dictionary()
    (bodyAttrs's setObject:bodyFont forKey:(current application's NSFontAttributeName))
    (bodyAttrs's setObject:bodyParaStyle forKey:(current application's NSParagraphStyleAttributeName))

    set headingAS to current application's NSAttributedString's alloc()'s initWithString:(headingText & return & return) attributes:headingAttrs
    set bodyAS to current application's NSAttributedString's alloc()'s initWithString:bodyText attributes:bodyAttrs

    set fullAS to current application's NSMutableAttributedString's alloc()'s init()
    (fullAS's appendAttributedString:headingAS)
    (fullAS's appendAttributedString:bodyAS)

    theView's textStorage()'s setAttributedString:fullAS

    set pdfData to theView's dataWithPDFInsideRect:theFrame
    set didWrite to pdfData's writeToFile:outPath atomically:true
    if didWrite is false then
        error "Failed to write PDF to " & outPath
    end if

    return outPath
end run
