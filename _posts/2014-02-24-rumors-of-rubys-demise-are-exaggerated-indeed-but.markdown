---
title: Rumors of Ruby's demise are exaggerated but...
layout: post
tags:
  - ruby
  - go
---

[Rumor's of Ruby's
demise](http://devblog.avdi.org/2014/02/23/rumors-of-rubys-demise/) are
exaggerated indeed. Ruby isn't going anywhere. And that's good because it's a
fantastic language for some things. For some things.

I believe main purpose of Ruby will end at running rails apps (like it is now),
mostly small-to-medium apps or just frontends for some larger systems.

The truth is the lack of built in, modern concurrency support in Ruby makes it
less fitting for many things. Especially the things that touch the ground of
networking (long persistent connections, not necessarily http) and coordination
of concurrent processes (processes in the sense of a unit of work, not OS).

Yes, you can make your Ruby code work fine at a larger scale, by optimizing it
here and there, using some techniques known to highly skilled Ruby programmers,
but that takes lots of effort. It's possible but just not elegant.

Let me give you an example:

I wanted to implement live streaming for [Asciinema](https://asciinema.org),
you know, "live session sharing", for remote pairing etc, without the tmux/ssh
hassle. That means (multiple) persistent connections to server from both
producers and consumers (watchers).  How do you do that in Ruby? You have some
options but they all have some serious cons. I recently spent ~month learning
Go, just for fun. And after a month I have written a simple (~130 loc) server
that streams terminal session to both a browser and to a terminal based client.
I can't say the code I wrote is perfect but when working on it it was really
pleasurable experience and it was straightforward to achieve what I wanted.

Of course I considered building this in Ruby in the first place. But every time
I started thinking about a possible solution I was finding that it's neither
straightforward nor pleasurable. Ruby doesn't like persistent connections. It's
awesome at serving some quick response but when you want to handle multiple,
long-running clients you have to either:
1) use JRuby + thread synchronization primitives,
2) Eventmachine,
3) Celluloid.

I don't want to synchronize threads (1) nor write evented code (2). Celluloid is
using fairly decent concurrency model (agents) and is closest to give me the
expected productivity/pleasure ratio. But still, I can write the same amount of
lines of code in Go and handle 100x more simultaneous clients using much less
memory.

Having said that I'm not saying it's impossible to build more complex,
distributed systems with Ruby. It's pretty much possible but you have to try
harder to achieve the end result.

You may say I'm wrong here. But it is what worked for me much better and
finally allowed me to write clean streaming code and solved the problem I
wanted to solve without giving me the pain while thinking of it. And I'll still
be happily building Asciinema website in Ruby. Right tool for the job.

YMMV.
