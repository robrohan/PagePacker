-- Prints the page count of a PDF file. Used to verify each generated zine
-- panel is exactly one page before handing it to PagePacker (a >1-page PDF
-- dropped on a page silently spreads across subsequent pages -- see
-- reference/layout_notes.md).
--
-- Usage: osascript pdf_page_count.applescript <pdfPath>

use framework "Foundation"
use framework "Quartz"
use scripting additions

on run argv
    if (count of argv) < 1 then
        error "Usage: pdf_page_count.applescript <pdfPath>"
    end if

    set posixPath to item 1 of argv as text
    set theURL to current application's NSURL's fileURLWithPath:posixPath

    set pdfDoc to current application's PDFDocument's alloc()'s initWithURL:theURL
    if pdfDoc is missing value then
        error "Could not open PDF: " & posixPath
    end if

    set pageCount to pdfDoc's pageCount()
    return (pageCount as integer) as text
end run
