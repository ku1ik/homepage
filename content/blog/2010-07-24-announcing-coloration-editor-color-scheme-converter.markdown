---
title: Announcing Coloration, editor color scheme converter
created_at: 2010-07-24 00:14
tags: textmate,vim,jedit,kwrite,kate,gem,ruby,converter
---

Without further ado I'm introducing Coloration - editor/IDE color scheme converter. It is an evolution of [tm2jed](/blog/tag/tm2jed) tool and
at the moment it can convert Textmate color themes (in XML plist format) to Vim, JEdit and Kate/KWrite/KDevelop color schemes. So if you are Textmate->Vim convert
or you just envy Textmate users for their good looking, dark themes now you have no excuse to not try out Coloration.

Here's how Vim with Sunburst theme looks like:

<%= image("/images/posts/gvim-sunburst-small.png", "/images/posts/gvim-sunburst.png", "Vim with Sunburst color scheme") %>

If you want to give Coloration a try you have two options. Either you can use online version at [coloration.sickill.net](http://coloration.sickill.net/)
or you can install ruby gem _coloration_:

    gem install coloration

It will give you _tm2vim_, _tm2jedit_ and _tm2katepart_ commands. Note it requires ruby 1.9.

Let me know if you find it useful. Source code is available at [github.com/sickill/coloration](http://github.com/sickill/coloration).

Enjoy!
