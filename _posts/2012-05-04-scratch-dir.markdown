---
title: Scratch dir
layout: post
tags:
  - shell
  - bash
  - zsh
---

"AUTOMATE ALL THE THINGS!" one would say. "Time is money." other would say.
"Don't make me think" another smart one would say. "Computers are our slaves and
we should put as much work as we can on their circuits" I say.

I'm constantly looking for automation opportunities in my daily working habits.
Today I automated one thing that was very simple but at the same time boring and
fully repeatable: creating temporary "scratch directory" and cd'ing to it.

Yesterday it was like this:

* I need a scratch dir...
* I'll create it in.... *~/tmp/* or */tmp/* ... let it be */tmp/*..
* `$ mkdir /tmp/` - stop, hmm, I need a name.. *q* then
* `$ mkdir /tmp/q`
* `mkdir: cannot create directory '/tmp/q': File exists`
* "Damn", *qq* then
* `$ mkdir /tmp/qq`
* `$ cd !$`
* Hooray! Wait, but what I need this dir for?

Today I created short shell function for zsh/bash:

    function new-scratch {
      cur_dir="$HOME/scratch"
      new_dir="$HOME/tmp/scratch-`date +'%s'`"
      mkdir -p $new_dir
      ln -nfs $new_dir $cur_dir
      cd $cur_dir
      echo "New scratch dir ready for grinding ;>"
    }

Thanks to above function I land in a brand new scratch dir. This dir is located in *~/tmp/* and it has unique name *scratch-{TIMESTAMP}*. Additionally there's symlink *~/scratch* pointing to it (always to the latest scratch dir) that is handy when you need to open another terminal/shell instance in this dir.

So today when I need a scratch dir:

    ~/code % new-scratch
    New scratch dir ready for grinding ;>
    ~/scratch %

One would ask: why shell function instead of shell script? Because shell scripts can't change current working directory of current (parent to them) shell. Shell functions run inside the current shell and can alter cwd.
