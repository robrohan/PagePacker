---
name: zine
description: Distill an HTML report, PDF, or research topic into an 8-panel pocket zine (cover, key-terms/notes panels, back cover) and assemble it in PagePacker via AppleScript, ending with a manual Print > Save as PDF step. Invoke when asked to make a zine, pocket booklet, or PocketMod-style pamphlet from a document, report, URL, or research findings.
argument-hint: <path/URL to source HTML or PDF, or a topic to research first> [output directory]
allowed-tools: Bash(osascript *), Bash(screencapture *), Bash(qlmanage *), Bash(open *), Bash(mkdir -p *), Bash(test *), Bash(grep *), Bash(ls *), Read, Write, WebFetch
---

Turns research (an HTML report, a PDF, a URL, or a topic you've just researched)
into a small 8-panel pocket zine assembled in PagePacker, PocketMod-style.

Read `reference/layout_notes.md` before starting -- it has panel dimensions, the
page-order-is-reading-order mapping, word budgets, and a list of real gotchas
found while building this skill. Don't skip it; several of them are non-obvious
and will silently break the output if missed (multi-page panel PDFs, closing the
document between steps, etc).

## Steps

**0. Preflight.**
```
test -d /Applications/PagePacker.app
```
If missing, stop and tell the user PagePacker needs to be installed/built first.
Query the panel size so dimensions match reality instead of assuming Letter:
```
osascript -e 'tell application "PagePacker" to get page size'
```
Letter -> 306x198pt panels (default assumption). A4 -> 297.5x210.5pt.

**1. Read and distill the source into 8 panels of content.**
Use `Read` directly on a local HTML or PDF path (PDFs: chunk by `pages` range if
long). Use `WebFetch` for a URL. If given a bare topic instead of a document, do
the research first, then distill it. Follow the word budgets and structure in
`reference/layout_notes.md`:
- Page 1 -- cover: title + one-line subtitle.
- Pages 2-7 -- six content panels, one heading each, drawn from the real material.
- Page 8 -- back cover: source attribution + short "generated" footer.

**2. Render each panel to its own single-page PDF.**
```
osascript scripts/render_panel.applescript "<heading>" "<body text>" "<outdir>/panel_0N.pdf" [width height]
```
Run once per panel (8 calls total). No HTML, no browser -- this draws the text
natively via AppleScriptObjC (the same `NSView`-to-PDF technique PagePacker's own
`PDFUtility.m` uses internally). Pass `width height` only if step 0 found A4.

**3. Verify every panel PDF before touching PagePacker.**
For each `panel_0N.pdf`:
```
test -s "<outdir>/panel_0N.pdf"
osascript scripts/pdf_page_count.applescript "<outdir>/panel_0N.pdf"   # must print 1
```
If any panel isn't exactly 1 page or is empty, something went wrong in step 2 --
fix and re-render before proceeding. Never hand a bad panel to PagePacker (see
the multi-page-bleed gotcha in `reference/layout_notes.md`).

**4. Assemble in PagePacker.**
```
osascript scripts/assemble_zine.applescript panel_01.pdf ... panel_08.pdf <outdir>/<slug>.pp
```
Creates a new document, drops each panel PDF onto its page via `file source`,
saves as `<slug>.pp`, and prints the assembled window's `CGWindowID` to stdout on
success. **Do not close PagePacker or the document after this step** -- printing
in step 6 depends on it staying open (see gotchas).

**5. Self-verify before telling the user anything is ready.**
`file source` has no readback property, so a successful `osascript` exit code
alone doesn't prove the panels actually loaded. Two checks, in order:
- Cheap heuristic: `grep -ac '%PDF' <outdir>/<slug>.pp` should be `>= 8`.
- Visual check (load-bearing, if available): `screencapture -l <windowID> -o -x
  <outdir>/<slug>_window.png`, then **Read** the PNG and confirm all 8 panels show
  real content, not blank placeholders. If `screencapture` fails outright (it
  needs macOS Screen Recording permission, granted once via System Settings ->
  Privacy & Security -> Screen Recording), don't treat that as a pipeline
  failure -- tell the user the visual check was skipped for that reason and fall
  back to the `%PDF` count as the signal.

**6. Trigger the manual print step.**
```
osascript scripts/print_zine.applescript
```
Opens PagePacker's native Print dialog on the still-open document. Tell the user
plainly: *"The Print dialog is open in PagePacker -- click the PDF dropdown in the
bottom-left, choose 'Save as PDF...', and save it (suggested:
`<outdir>/<slug>.pdf`)."* This is a real, unavoidable manual step -- PagePacker's
`print` command silently ignores any settings/output path passed via AppleScript,
and `save` never produces a PDF. Do not attempt to script past this point.

**7. Verify the final artifact** once the user confirms they've saved it:
```
test -s <final>.pdf
qlmanage -t -s 1024 -o <outdir> <final>.pdf
```
Then **Read** the generated thumbnail PNG as a last visual sanity check before
declaring the zine done. Note: the flattened export is one physical sheet showing
the full 2x4 panel grid (PagePacker prints the whole layout view, not 8 separate
PDF pages) -- a page count of 1 here is correct, not a failure sign.

## Output location

Default: `~/Documents/PagePacker Zines/<slug>-<YYYY-MM-DD>/`, where `<slug>` is a
short kebab-case name derived from the topic/source title. Keep everything from
one run together there: the 8 panel PDFs, the `.pp` source-of-truth doc, the
self-check screenshot (if produced), and the final flattened PDF. This is
generated user content, not project source -- don't put it inside the git repo.
If the user passes an explicit output directory as a second argument, use that
instead.

## Style guidance

System sans-serif, heading ~14-16pt bold / body ~9-10pt (`render_panel.applescript`
defaults to this). Short, punchy phrasing over full sentences -- the panel is
narrow. Stick to the word budgets in `reference/layout_notes.md`; overflow clips
silently rather than shrinking or paginating.

Images are out of scope for now -- favor extracting a diagram's insight as
text/bullets instead of trying to shrink an image into a 2.75in-tall panel.
