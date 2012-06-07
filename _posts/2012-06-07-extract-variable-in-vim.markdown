---
title: Extract variable in Vim
layout: post
tags:
  - vim
---

Given you are working on following code in Vim (cursor position is `|`):

    for strawberry in |Strawbery.where(size: 'xxl')
      puts "Oh look, a #{strawberry.size} strawberry!"

You want to extract `Strawbery.where...` into a variable. Recently I've learned
that typing `<C-a>` in insert mode inserts the characters that were typed
previously in insert mode. Let's use it to extract a variable:

    Cstrawberries<ESC>O<C-a> = <ESC>p

After using above key combo you end up with this:

    strawberries = Strawbery.where(size: 'xxl')|
    for strawberry in strawberries
      puts "Oh look, a #{strawberry.size} strawberry!"

Profit.
