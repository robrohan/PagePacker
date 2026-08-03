# PagePacker

PagePacker is a macOS application that helps you build little pocket sized notebooks and physical zines from a single page of paper.

> Don't want to compile it yourself? You can purchase the app directly at [therohans.com/pagepacker/](https://therohans.com/pagepacker/).

PagePacker was written in the early 2000s It was originally created by _Big Nerd Ranch_ and written by _Aaron Hillegass_. [Original
Post](https://web.archive.org/web/20140617173248/http://www.bignerdranch.com/blog/pagepacker-makes-pocket-sized-books/)

I found the application quite useful, for on-the-go notes and making little pocket zines for local meetups and conference pamphlets.

Here is what the application looks like:

![PagePacker screenshot](img/screenshot.png)

Folding instructions:

![Folding image](img/folding.jpg)

## Claude Code skill: build a zine automatically

PagePacker is AppleScript-scriptable, so this repo includes a [Claude Code](https://claude.com/claude-code)
skill (`.claude/skills/zine/`) that turns an HTML report, PDF, or research topic
into a little 8-panel pocket zine and assembles it in PagePacker for you.

You don't need to check out this repo's source to use it — just PagePacker
itself installed (from [therohans.com/pagepacker/](https://therohans.com/pagepacker/)
or wherever you got it) and the skill folder pulled down on its own:

```sh
mkdir -p ~/.claude/skills/zine
curl -sL https://github.com/robrohan/PagePacker/archive/refs/heads/master.tar.gz \
  | tar -xz -C ~/.claude/skills/zine --strip-components=4 PagePacker-master/.claude/skills/zine
```

That pulls just the skill's files (no Xcode project, no templates, nothing else
from the source tree) straight into `~/.claude/skills/zine`, so it's available in
any project you use Claude Code in. If you'd rather it only apply to one project,
change the `-C` target above to that project's `.claude/skills/zine` instead.

Once it's there, just ask Claude Code something like *"use the zine skill to
make a pocket zine from this article"* and it'll take it from there.

## Is this the original?

When I went looking for the application, it seems it had fallen into the void of the internet.

Luckily, Aaron open sourced the application back in 2007:

> Aaron Hillegass	
> November 5, 2007 | Mac	
> I am celebrating the arrival of Mac OS X 10.5 by making the source code to PagePacker available. Here is the compiled application.

With a bit of digging around I've found the original application source, and tried to updated it to the latest version of macOS (Tahoe os26 as of this writing).

## Media & Art References

This was written by Aaron Hillegass who taught Cocoa programming at Big Nerd Ranch, Inc. (a now non-existent company).

To write the app was Nate Osborne's idea. He was inspired by PocketMod. See http://www.pocketmod.com/ for details.

The original templates were released under **Creative Commons Attribution Non-Commercial No-Derivatives
license** so they have been removed from the binary release, but can be found in the [Non-Free](./Non-Free) directory if you are looking for the originals.

Matt Neuberg made PagePacker AppleScriptable.

The icon was created by Kyle Mistry: http://kylepoint.com/

The Japanese localization was done by Joshua Done.

This software and its source code are released by Big Nerd Ranch, Inc. under the BSD License.

