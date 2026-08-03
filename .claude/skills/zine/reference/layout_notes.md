# Zine layout notes

Facts verified against PagePacker's Objective-C source and confirmed by hands-on
testing during development of this skill. Read this instead of re-deriving from
the source each run.

## Panel geometry

- A document has exactly 8 fixed pages/panels (`PackModel.h`: `BLOCK_COUNT 8`), laid
  out 2 columns x 4 rows on one physical sheet.
- Letter sheet (612x792pt) -> panel = **306 x 198pt** (4.25in x 2.75in).
- A4 sheet (595x842pt) -> panel = **297.5 x 210.5pt**.
- Query which one is active at runtime rather than assuming:
  `tell application "PagePacker" to get page size` -> returns `letter` or `A4`.
  Default to Letter (306x198pt) unless this returns `A4`.
- `PackerView.m`'s `drawImageRep:inRect:isLeft:` aspect-fits and centers whatever's
  dropped into the panel rect, so panel PDFs don't need pixel-perfect media boxes --
  but generating them at the exact panel size (as `render_panel.applescript` does)
  avoids any fit/crop surprises.

## Page order = reading order (no grid math needed)

AppleScript `page 1` ... `page 8` on a `document` are already in **final reading
order**, not raw print-sheet position. `PackerView.m`'s `fullRectForPage:` /
`isLeftSide()` scramble the physical print-sheet layout internally (that's the
whole point of the app) -- the skill just maps:

| Page | Content |
|---|---|
| 1 | Front cover: title + one-line subtitle |
| 2-7 | Six content panels, one clear heading each |
| 8 | Back cover: source attribution + colophon |

**Always author panel content right-side-up.** The 0deg/180deg rotation
PagePacker applies per column at draw time is correct, expected pocketmod-fold
behavior -- never pre-rotate to compensate.

## Word budget per panel

Panels are a 4.25in x 2.75in note-card at ~9-10pt body text with ~14pt margins --
treat these as hard ceilings, not targets:

- **Cover (page 1):** ~5-10 words (title + subtitle).
- **Content panels (pages 2-7):** one heading + **~90 words max** body (3-5 short
  bullets or one short paragraph + 1-2 bullets). `render_panel.applescript` clips
  silently on overflow -- it does not paginate or shrink to fit -- so staying under
  budget matters more than it would with a normal print pipeline.
- **Back cover (page 8):** ~15-25 words.

Natural panel headings to pick from based on the source material: "Key Terms",
"TL;DR", "Timeline", "Notable Quote", "Why It Matters", "Open Questions", "Numbers
to Know" -- use whichever ones actually fit the content, don't force all of them.

## Known gotchas (found during development)

- **`file source` is write-only**, no readback property, and `PackModel.m`'s
  `putFile:` silently no-ops on a bad/unreadable file with no thrown AppleEvent
  error. AppleScript-level error catching alone cannot prove a panel was accepted.
- **A multi-page PDF dropped on page N silently spreads across pages N, N+1, N+2...**
  (`PackModel.m putPDF:startingOnPage:`). Always verify each panel PDF is exactly
  one page (`pdf_page_count.applescript`) before handing it to
  `assemble_zine.applescript`.
- **Do not close the PagePacker document between assembling and printing.**
  `assemble_zine.applescript` leaves the document open on purpose.
  Re-opening a saved `.pp` file via AppleScript's `open` command (or the macOS
  `open` shell command, which goes through the same LaunchServices path) was
  found to silently fail during development -- the app accepts the request but no
  document actually appears, with no error and nothing in Console/crash logs. There
  is no known reliable scripted fallback for this; if the document gets closed
  before printing, ask the user to reopen it themselves from inside PagePacker
  (File > Open) rather than trying to script around it.
- **`print`'s scripted settings are ignored** (`MyDocument.m`
  `printOperationWithSettings:` never merges the passed dict into the live
  `NSPrintInfo`), and `save` only ever writes the native `.pp` format, never a PDF.
  There is no headless path to a flattened zine PDF -- `print document 1 print
  dialog true` opens the real Print dialog, and a human has to choose PDF > "Save
  as PDF..." from it. Don't try to script past this point.
- **The self-verify screenshot step needs macOS Screen Recording permission**
  granted to whatever process runs `screencapture` (Terminal, or Claude Code's
  host process). Without it, `screencapture` fails outright (even a plain
  full-screen capture, not just `-l <windowID>`) with no usable window content --
  this is a one-time System Settings > Privacy & Security > Screen Recording grant
  only the user can make. If it's not granted, warn and skip the visual check
  rather than treating it as a hard failure -- the `.pp` file's `%PDF` header count
  (see below) is a reasonable fallback signal.
- **ASObjC syntax note for anyone editing `render_panel.applescript`:** calling a
  zero-argument Cocoa method that returns a C struct (e.g. `theView's bounds()`)
  breaks the AppleScript parser (`Expected end of line... (-2741)`) when stored
  directly. Build the rect with `current application's NSMakeRect(...)` and reuse
  that variable instead of calling `bounds()`.

## Cheap verification heuristics

- `test -s <file>` -- exists and non-empty.
- `osascript scripts/pdf_page_count.applescript <panel.pdf>` -- expect `1` for
  every panel.
- `grep -ac '%PDF' <slug>.pp` -- expect `>= 8` (each embedded panel's raw PDF bytes
  carry their own `%PDF` header inside the saved document). Not proof by itself,
  but a useful zero-cost second signal when the screenshot check isn't available.
