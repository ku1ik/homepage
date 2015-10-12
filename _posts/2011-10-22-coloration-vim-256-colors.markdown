---
title: Coloration + terminal Vim + 256 colors
layout: post
tags:
  - vim
  - coloration
---

Year has passed since last [Coloration](http://coloration.sickill.net/)
update. Time has come for new improvements. Brand new Coloration v0.3.1
focuses on Vim theme writer and includes:

* Line numbering (`LineNr`) background matching cursor line highlight style
  (`CursorLine`)
* New style for `ColorColumn` also matching cursor line highlight
* **Highlighting for terminal Vim running in 256 colors capable terminal**

Let's focus on the last one.

Nowadays most terminal emulators support 256 colors. Additionally to 16 base
colors everyone knows about they also support 216 colors from 6x6x6 color cube
and 24 shades of grey. Look
[here](http://www.mudpedia.org/wiki/Xterm_256_colors) for details. If you don't
use 256 colors capable terminal then start using it now. `xterm` had it in
1999. `gnome-terminal`, `konsole`, `iTerm2` and many more have it.

Vim colorschemes allows you to specify `ctermfb` and `ctermbg` from the range
0-255. People usually only use 0-15 in their themes in order to be compatible
with _16-color-my-grandpa-uses_ terminals. That's so wrong! Coloration is
fast-forwarding us to the future with it's updated Vim theme writer. It
converts the colors used by the gui Vim version (GVim/MacVim) to their xterm256
nearest equivalents with simple approximation.

Sunburst theme converted from Textmate theme:

![Sunburst theme in Vim](/images/posts/coloration-1.png)

Twilight theme converted from Textmate theme:

![Twilight theme in Vim](/images/posts/coloration-2.png)

Now [go convert](http://coloration.sickill.net/) your old, dusty Textmate
themes. Oh, and I've put Sunburst and Monokai themes on github
([vim-sunburst](https://github.com/sickill/vim-sunburst),
[vim-monokai](https://github.com/sickill/vim-monokai)) for all you lazy
guys.
