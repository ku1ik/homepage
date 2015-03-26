---
title: My 2015 Programming Languages Tool Belt
layout: post
tags:
  - rails
  - ruby
  - haskell
  - scala
  - elixir
  - clojure
  - go
  - rust
---

A friend of mine approached me recently with a question: "What are your current
thoughts on go-to platforms for building web apps? What would you choose for a
web app? Ie. app that both should work as API, admin console, some end user
facing stuff, etc".

Because this is a topic I've been recently researching I find a reply to this
question a fantastic way to express my current point of view. Let me first set
the background and tell you where I'm coming from.

I started programming in
[AMOS](https://en.wikipedia.org/wiki/AMOS_%28programming_language%29)
programming language, back in the days when Amiga 600 was a masterpiece of
engineering, that every kid desired. Then I used Pascal, C, x86 assembly, C++,
PHP, Java, C#, Python, JavaScript. Then, 8 years ago I started using Ruby as my
primary language. I loved it for many years. I don't love it any more, but I
still appreciate some of its aspects.

The change to my relationship with Ruby correlates with my interest in
programming languages in general, and getting familiar with the ones that
showed up in the last ~decade in particular.

Let's come back to my friend's question. Even though he asked about "go-to
platform for web apps" I replied with a list of languages I would consider
using for building software in general these days - my programming languages
tool belt. The list includes both the ones I'm familiar with and the ones I'm
looking at from a close distance. It doesn't include my pre-Ruby languages
though, as I either don't enjoy them anymore or I simply find them problematic
these days.

Here's what I replied to him (edited):

**Ruby/Rails.** These days I find Ruby not really well suited to anything
that's more complicated than a simple CRUD app or a reasonably simple API. I've
been using it professionally for 8 years, and I've seen too many Ruby (Rails in
particular) apps grow and become a mess which is extremely hard to work with
and reason about. And that includes projects built and maintained by
experienced software engineers too. That's in part because of the "Rails Way",
which leads to achieving results quickly, and in part because of the Ruby
language itself. In last few years I've seen many Ruby/Rails developers looking
for solutions to build bigger things with this stack. But it requires a hell
lot of a discipline and experience from the *whole* team. Also, by not
following the "Rails Way" you loose ability to benefit from the Rails ecosystem
and its plethora of ready made gems. The other part is Ruby, which is a very
unpredictable and unreliable language. No proper namespaces/imports so
everything is essentially global. Everything is mutable during runtime. Good
luck chasing issues in your app after adding a new gem to your Gemfile which
happens to monkey patch something etc. And last but not least dynamic typing
doesn't "scale" in Ruby (does it scale anywhere else?). After writing several
things in statically typed languages I don't trust most of Ruby code (even
mine!). Every change brings anxiety and requires additional tests that check
things that you wouldn't have to check if you used a language with static
typing. I could go on about Ruby/Rails for hours :) But my opinion these days
is that this stack is nice to build something simple very quickly.
Sustainability and reliability is not its biggest strength. Job market
visibility is pretty high though so it's worth having it in your skill set if
you're deep into "web" apps.

**Go (aka Golang).** Given a fair amount of lines of code I wrote in Go I think
I got to a point where I finally see its use cases clearly. It was a perfect
match for [git-archive-daemon](https://github.com/gitorious/git-archive-daemon)
and [gitorious-proto](https://github.com/gitorious/gitorious-proto) (ssh and
http repository access). It brought safety and speed to this critical piece of
Gitorious backend. It really shines when you do systems and/or networking
stuff. On the other side, it kinda sucks when it comes to modeling domain
logic. It's neither OO (structs with behavior but that's it), nor functional
(has closures, has functions as first class citizens, but no functional
constructs), and while being statically typed it doesn't have generics which
makes you write the same boring, imperative code for anything that is slightly
higher level. Concurrency built into the language in the shape of channels and
Goroutines makes it a fantastic fit for building robust, high-scale,
multi-core, networked apps though. It's great for command line apps too,
because these don't usually have lots of business logic, most often they deal
with files, streams and network, and it's awesome to have a single
self-sufficient binary for distribution. I'm not sure if I would build a whole
"web app" (API, client facing pages, admin part) in Go. Probably not. I'd
probably limit the Go part to API, but only provided that the business logic
isn't very rich in that case. I haven't written an actual "web app" in Go yet,
but I have a strong feeling that it is too low-level for that. I can also see
risks when it comes to finding libraries that relate to other stuff than
systems/networking. That's probably one of the reasons why I would be cautious
when considering it for a typical web app. One thing I'd like to point out here
is its learning curve. Go is one of the most easy to learn languages out there
due to its explicitness, simplicity and thin syntax surface.

**Clojure.** It's a language I now use in place of Ruby (when I can). It solves
many of the problems I have with Ruby. It has proper namespaces/imports,
immutable data structures and trivial syntax (it's pretty much only an AST
after all).  These 3 alone put it in a more favorable position than Ruby when
it comes to building something slightly bigger. It's very pragmatic - it's
highly functional but it allows you to use atoms, refs and other state-keeping
constructs when you really need them. It also allows you to access IO with no
fuss (spit/slurp functions for example), contrary to other functional languages
like Haskell, where IO is pushed to [I/O
Monad](https://www.haskell.org/tutorial/io.html).  This makes it a really
approachable functional language. Thanks to macros it supports pattern matching
([core.match](https://github.com/clojure/core.match)), gradual typing
([core.typed](https://github.com/clojure/core.typed)) and sane async
programming, similar to Go
([core.async](https://github.com/clojure/core.async)). So I see Clojure as a
"much better Ruby, which runs on JVM" (and I think being on JVM is a plus
here). Clojure is dynamically typed just like Ruby (which also has many
functional constructs), hence the comparison here. Oh, it also has
ClojureScript/Om which brings sanity to building rich browser UIs \o/. One
downside of Clojure is its low position on job market. It's getting better with
every year though.

**Haskell.** I haven't used Haskell on a real-world project yet but it seems to
have all the ingredients I'm looking for in a language today: functional,
immutability, serious type system, powerful pattern matching, and failure
handling with Maybe type. Btw, I talked to a guy on LambdaDays conf recently
who owns a consulting company that began as a Rails shop and now they're moving
towards building their web apps in Haskell. 6 out of 25 Ruby devs switched to
full time Haskell already, and more to come. Interesting, isn't it?

**Scala.** This one got my attention recently again. It has more or less the
same qualities I find in Haskell: functional (mostly), immutability (mostly),
static typing with generics, Option (Maybe) type, powerful pattern matching. I
wrote some [small piece of code in
Scala](https://github.com/sickill/finish-him) some time ago, but I did it in a
very imperative, and not really idiomatic style back then. I'm inclined to try
it out again on some side project, there are several things which put me off a
bit though. It's very close to Java, so it's close to XML/SOAP/Enterprise
ecosystem and type of work/projects. It also has like a half-dozen types
meaning "nothing": Null, null, Nil, Nothing, None, and Unit. O_o. This may be
nitpicking but it doesn't show it as a consistent and simple language IMHO. And
its "syntax surface" feels to be very wide, which is something I try to avoid
these days. From HR POV it's definitely not as "dramatic" as Haskell or
Clojure.

**Rust.** I looked at it recently and I find it to be a way better designed
language than Go (if we compare languages advertised as "systems language").
Functional constructs built-in, immutability, static typing with generics,
Option type, powerful pattern matching, and no exception handling (solved by
Option). <3 <3 <3. However, there's one thing I miss in Rust: garbage
collector. I understand why it's not there. They (Mozilla) wanted systems
language with predictable performance, that would replace C++. And I think it
delivers on that promise. But that makes it a bit too complicated (memory is
managed for you but with your help) and not well suited for building web apps.
I guess I could have skipped Rust in this already long list, but I love
discussing programming languages recently, sorry. Note that I compared Rust to
Go in the first sentence of this paragraph, but it's only because both are
called "systems" languages. In reality they seem to have different use-cases
and excel in different niches.

**Elixir.** It's on my list of languages to have a closer look at. It builds on
Erlang/OTP and as Erlang it is best suited for building scalable,
fault-tolerant distributed systems. It's dynamic, functional, has pattern
matching and includes several Ruby-inspired features like modules/mixins and
similar syntax. [Phoenix](https://github.com/phoenixframework/phoenix) seems to
be its most popular web framework. If I had to compare it to other language
from this list it would probably stand somewhere near statically typed Scala
with AKKA toolkit/runtime. Feel free to bash me for this comparison.

So, this list didn't really give a direct answer to my friend's question. But I
hope it is still useful for him and anyone else looking for a great tool to fit
for the next job. There's no single programming language that excels in
everything and it's important to understand that languages are just tools.
Sometimes I'm choosing multiple languages for different components of a single
system (Gitorious' frontend was a Rails app, its backend was built in Go and
bash).  Sometimes I'm building UI as a HTML5/JS/ClojureScript app, fully
decoupled from the backend. It all varies from case to case.

I hope to have lots of opportunities to try more of these "tools" in the
future, finding out how well they fit specific applications, and adding the
proven ones to my programming languages tool belt.

I'd love to discuss this topic more so I'm looking forward to your opinion on
this!
