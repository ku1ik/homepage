---
title: systemd socket activation and Ruby
layout: post
tags:
  - ruby
  - systemd
---

For anyone who doesn't know what systemd is:

> systemd is a system and service manager for Linux, compatible with SysV and
> LSB init scripts. systemd provides **aggressive parallelization**
> capabilities, uses **socket and D-Bus activation** for starting services,
> offers **on-demand starting of daemons**, keeps track of processes using
> Linux cgroups, supports snapshotting and restoring of the system state,
> maintains mount and automount points and implements an elaborate
> transactional dependency-based service control logic.
>
> [www.freedesktop.org/wiki/Software/systemd](http://www.freedesktop.org/wiki/Software/systemd)

It's quite similar to Apple's launchd (used in OSX) and is fully utilizing
powerful features of the latest Linux kernel. systemd is default init system in
latest Fedora, openSUSE and Mandriva and is available for many other Linux
distros as alternative boot solution. I hope Ubuntu's upstart team will give up
soon because having systemd on Ubuntu servers would be awesome. For more info
and idea behind the project I recommend reading [Lennart Poettering's
announcement](http://0pointer.de/blog/projects/systemd.html)

One of the great features of this init system is [socket
activation](http://0pointer.de/blog/projects/socket-activation.html) of system
services. In short, services are lazily started when they're actually needed.
Systemd listens on the sockets for them and starts the services on first
incoming connection, passing them the listening sockets. Started services just
start accepting clients on these sockets (without calling
`socket()+bind()+listen()`).

It appears that the protocol for passing sockets to service processes is very
simple. Environment variable *LISTEN_PID* is set to the PID of the service
process and another environment variable *LISTEN_FDS* is set to the number of
listening sockets passed. Socket descriptors start from number 3 and are
sequential. For example, *LISTEN_FDS* with value of 2 means process should
accept connections on 2 sockets with descriptors 3 and 4.

I'll show you how all this works on an example echo server written in ruby. The
server will send back what it receives. Additionally it will send information
telling if listening socket came from systemd or not to each new connected
client.

But first we need to create the socket unit file that specifies where systemd
should listen on behalf of our service.
_/etc/systemd/system/echo-server.socket_ file can look as simple as this:

    [Socket]
    ListenStream=8888

Next, we need service unit file that specifies what binary to start when
connections start coming. _/etc/systemd/system/echo-server.service_ file may
look like this:

    [Service]
    ExecStart=/home/kill/.rvm/bin/ruby-1.9.2-p290 /home/kill/bin/echo-server.rb
    User=kill
    StandardOutput=syslog
    StandardError=syslog

I have ruby 1.9.2 installed via RVM so I'm running my ruby script with RVM's
wrapper specifying full paths (remember init process runs as root). I'm also
setting the user on whose behalf the process should be run and I'm asking
systemd to log process' stdout/stderr to syslog (simplifies debugging).

Now, the echo server (_/home/kill/bin/echo-server.rb_):

    #!/usr/bin/env ruby

    require 'socket'

    SD_LISTEN_FDS_START = 3

    from_systemd = false

    if ENV['LISTEN_PID'].to_i == $$
      # use existing socket passed from systemd
      server_socket = Socket.for_fd(SD_LISTEN_FDS_START + 0)
      from_systemd = true
    else
      # create new listening socket on port 8888
      server_socket = Socket.tcp_server_sockets(8888)
    end

    Socket.accept_loop(server_socket) do |client_socket, addr|
      client_socket.send("OHAI! systemd socket: #{from_systemd}\n", 0)

      while (data = client_socket.recv(1000)).size > 0
        client_socket.send(data.upcase, 0)
      end
    end

Implementation is very simple, still I'm gonna explain it a little bit as it
illustrates the use of systemd socket activation protocol and the fallback -
normal way of creating server socket.

Like I mentioned earlier, descriptors of systemd passed sockets start with 3:

    SD_LISTEN_FDS_START = 3

We check if *LISTEN_PID* points to our echo-server.rb process:

    if ENV['LISTEN_PID'].to_i == $$

If so, we're creating new `Socket` instance for existing descriptor (3). Socket
unit file tells systemd to listen on one port only (8888) so we can assume
there's only one socket descriptor passed:

      # use existing socket passed from systemd
      server_socket = Socket.for_fd(SD_LISTEN_FDS_START + 0)

If *LISTEN_PID* doesn't match our process we just create TCP socket the usual
way:

    else
      # create new listening socket on port 8888
      server_socket = Socket.tcp_server_sockets(8888)
    end

Finally, in `Socket.accept_loop(server_socket) do { ... }` we handle incoming
clients.
