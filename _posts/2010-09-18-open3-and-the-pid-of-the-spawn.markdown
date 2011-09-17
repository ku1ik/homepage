---
title: Open3 And The PID Of The Spawn
layout: post
tags:
  - ruby
  - system
  - mri
  - rubinius
  - jruby
img: http://farm4.static.flickr.com/3182/2715910858\_e70a4891e2.jpg
---

Open3 is a standard way of starting subprocess from ruby if you need IO objects for stdin, stdout and/or sterr.
It goes like this:

    require "open3"

    stdin, stdout, stderr = Open3.popen3('sort')
    stdin.puts "oso de peluche"
    stdin.puts "del ratón"
    stdin.close
    while !stdout.eof?
      puts stdout.readline
    end

Simple. I needed one more thing: PID of the spawned process to be able to send it some SIGNALs.
After looking at [open3 docs](http://ruby-doc.org/core/classes/Open3.html) I realized there is no way to get the PID.
Several posts like [this one](http://blog.tewk.com/?p=74) made me believe that [open4](http://github.com/ahoward/open4)
is the only way to go.

But I didn't gave up. I didn't want to add open4 as a dependency of my code only because of this small shortcoming.
After a while of googling I found [open3 documentation for ruby 1.9](http://ruby-doc.org/ruby-1.9/classes/Open3.html).
How it's different?

"Open stdin, stdout, and stderr streams and start external executable. In addition, a thread for waiting the started
process is noticed. The thread has a thread variable :pid which is the pid of the started process."

Hurray!

    stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
    pid = wait_thr[:pid]  # pid of the started process.
    Process.kill("USR1", pid)  # send it USR1 signal

So MRI 1.9 solves the problem by returning additional element with reference to waiting thread with :pid variable set on it.
How about other ruby implementations?

JRuby doesn't return waiting thread reference from open3() call but it has open4 incorporated into its standard library in
the shape of IO.popen4 method:

    pid, stdin, stdout, stderr = IO.popen4(cmd)

Unfortunately, both MRI 1.8.x and Rubinius don't include this functionality in their standard lib.

So, is open4 the only reliable way? Let's see:

MRI 1.8.7:

    ruby-1.8.7-p249 > open4 "cat"
     => [31373, #<IO:0xb741c8ac>, #<IO:0xb741c870>, #<IO:0xb741c7f8>]

MRI 1.9.2:

    ruby-1.9.2-p0 > open4 "cat"
     => [31498, #<IO:fd 4>, #<IO:fd 5>, #<IO:fd 7>]

JRuby:

    jruby-1.5.2 > open4 "cat"
    NotImplementedError: fork is unsafe and disabled by default on JRuby
            from /home/kill/.rvm/gems/jruby-1.5.2/gems/open4-1.0.1/lib/open4.rb:23:in `popen4'

Rubinius:

    rbx-1.0.1-20100603 > open4 "cat"
     => [31635, #<IO:0x212>, #<IO:0x214>, #<IO:0x216>]

Damn, looks like we cannot use open4 under JRuby. Fortunately, there is IO.popen4 which should be used instead.
Solution that will work in all ruby implementations might look like this:

    if IO.respond_to?(:popen4)
      def open4(*args)
        IO.popen4(*args)
      end
    else
      require 'open4'
    end

    open4("cat")

Summarizing, go with open4/IO.popen4 if you want to be sure your code works on all ruby implementations.
