---
title: Formatting XML in Vim with indent command
layout: post
tags:
  - vim
  - xml
---

Today I had a need to look at XML doc fetched from [Google Calendar API](http://code.google.com/apis/calendar/data/2.0/developers_guide.html). I saved it to a file and opened in Vim. Unfortunately API output was generated to be consumed by machines rather than humans.

First I tried `gg=G` command. **=** is used to auto-indent selected line(s) and `gg=G` re-indents whole file. Usually it works great, especially for source code files. It does not reformat code, it only changes indentation. And that's good, **I** should be the one to control look of my code. But for XML I want it to do full reformatting. I'm not writing XML and in all of the cases when I open such docs in my editor I only want to look at well-formatted, human-readable XML.

From Vim help on _equalprg_ setting:

> External program to use for "=" command.  When this option is empty
> the internal formatting functions are used; either 'lisp', 'cindent'
> or 'indentexpr'.  When Vim was compiled without internal formatting,
> the "indent" program is used.
> ...

"Bingo! Let's use _xmllint_ for that!" - I thought immediately. _xmllint_ command comes bundled with _libxml_ package on Unix-like systems and does really good job at producing pretty output. You can use it like this:

    # shell
    xmllint --format --recover foo.xml

Okee, so my first approach to reformatting XML in Vim was:

    :1,$!xmllint --format --recover - 2>/dev/null

Not bad. But writing it every time (or remembering) would be painful. Let's use mentioned _equalprg_ option:

    # .vimrc
    set equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

Ok... but Y U USE XMLLINT WHEN I'M INDENTIN' MY RUBY CODE?? Ahaa! _equalprg_ need to be set locally only for XML-type buffers. Autocommand did the trick:

    # .vimrc
    au FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

Restarted Vim, typed `gg=G` and said "Hell yeah!".
