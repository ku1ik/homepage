---
title: Bitpocket as a Dropbox alternative
layout: post
tags:
  - bash
  - bitpocket
  - dropbox
  - rspec
  - rsync
  - shell
---

As an excuse for trying out [Posterous](http://posterous.com) email
posting and its Autopost feature (in this case to Twitter and
Identi.ca) I'll present you Bitpocket.

In short, Bitpocket is a small but smart bash script that does two-way
directory synchronization resembling Dropbox sync. Simply it just uses
_rsync_ to make the actual sync. It runs rsync twice: first syncing
from remote to local machine, then from local to remote machine. This
way all new files that appeared on remote are fetched to local machine
and all new locally created files are replicated on remote machine.

But additionally it makes sure that file deletion is properly
propagated in this 2-way synchronization, which isn't possible by
_just_ running rsync twice. The problem is rsync deletes all new
created files or brings back the files you deleted
depending on which direction we sync in first (and when using _--delete_ option). Bitpocket solves that
by tracking names of created and deleted files between its invocations
and using these lists as a source for _--exclude-from_ rsync option
when doing first, remote -&gt; local sync.

To make sure Bitpocket behaves like I wanted it to behave I've
[spec'ed it](https://github.com/sickill/bitpocket/blob/master/spec/bitpocket_spec.rb).
Yes, it's a bash script, not a ruby code, but who said I can't use
rspec to test a bash script?

For details about usage see [Bitpocket's
README](https://github.com/sickill/bitpocket). I'm using it instead of
Dropbox for few weeks now and it does quite good job. Give it a try.
