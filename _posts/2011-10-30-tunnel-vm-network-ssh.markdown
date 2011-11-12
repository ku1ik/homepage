---
title: Tunnelling VirtualBox guest's network traffic
layout: post
tags:
  - ssh
  - virtualbox
  - network
---

This post is quite different than my usual ones. It's not about programming
at all. Usually I'm not writing about how I solve various, non-programming
related problems but this time I want to share what I achieved as this may be
helpful to others facing similar scenario. I couldn't find similar solution
explained anywhere so I'm putting this for anyone seeking such information.

## The problem

_Tunnel whole network traffic of VirtualBox guest machine through remote
server located in different country._

Basically what I needed was a virtual machine that was connecting to internet
with London's IP address. Simple port forwarding was not an option as the
machine needed to connect from many apps (not only web browser) to multiple
(unknown to me) hosts and ports.

## The idea

_Setup SSH tunnel from my local machine (VirtualBox host) to my Linode server
in London and tell VirtualBox to use this tunnel as guest VM's ethernet
interface endpoint._

Seems simple. And after a few failed attempts it turned out to be really
simple. You just need to know few concepts and run few commands here and there.

## The solution

Below is the complete solution that worked well for me. I use following symbols
for involved machines:

* P - remote machine with London's IP, used as a **p**roxy
* H - local machine, VirtualBox **h**ost
* G - virtual machine, VirtualBox **g**uest, needs public IP of P

Solution is build on OpenSSH-based VPN. From [waldner's
post](http://backreference.org/2009/11/13/openssh-based-vpns/) at
[backreference.org](http://backreference.org/):

> This is a poorly documented yet really useful feature of Openssh. It allows you
> to connect two tun/tap interfaces together, to create a layer-2 or layer-3
> network between remote machines. This results in OpenVPN-like VPNs (but much
> simpler and, admittedly, less scalable).

With presented solution virtual machine (guest) can be running any OS: Linux,
Windows, whatever.

### Foreplay

You need to have root access on the machine that will work as a proxy (P). This
machine needs to have _eth0_ interface configured with public IP address
(London in my case).

The sshd running on it should allow root logins (I'll explain later why) and
setting up ssh tunnels. Make sure you have following entries in
`/etc/ssh/sshd_config` on P:

    # /etc/ssh/sshd_config

    PermitRootLogin yes
    PermitTunnel yes

Restart sshd if needed.

### Step I

First you need layer-2 (ethernet) ssh tunnel. Run following on H as root:

    $ ssh -o Tunnel=ethernet -w 0:0 root@<P hostname>

replacing `<P hostname>` with real hostname of your proxy machine.

This will setup L2 link and create _tap0_ network interfaces on both machines
(H and P). Because only privileged users can create network interfaces you need
to run this command as root, ssh-ing to remote host as root user as well.

_\* `0:0` in above command specifies numbers for _tap_ interfaces for both
machines. You can safely use 0 for both of them as you probably don't have any
other existing tap interfaces._

### Step II

Now you need to create
[NAT](http://en.wikipedia.org/wiki/Network_address_translation) on the proxy
machine (P). This will make traffic from _tap0_ interface to be seen with P's
public IP address (going through its _eth0_ interface).

Run following on P as root:

    $ echo 1 > /proc/sys/net/ipv4/ip_forward
    $ /usr/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    $ /usr/sbin/iptables -A FORWARD -i eth0 -o tap0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    $ /usr/sbin/iptables -A FORWARD -i tap0 -o eth0 -j ACCEPT

Masquerade ready. Now bring P's _tap0_ interface up and configure it:

    $ ifconfig tap0 up
    $ ifconfig tap0 192.168.0.1 netmask 255.255.255.0

_\* You can use different network than 192.168.0.\* for NAT if P is already
attached to such network._

### Step III

Next step is to bring H's _tap0_ interface up. Run following on local machine
(H) as root:

    $ ifconfig tap0 up

There is no need to assign IP to this interface as it will be directly
connected to virtual machine's network interface.

### Step IV

Now configure virtual machine to use the tunnel.

Open VM network settings (on H), select _Bridged adapter_ and choose _tap0_ as a
bridged device.

### Step V

Finally start virtual machine (G) and configure its network interface.

The guest machine can be either Linux or Windows (or just anything you want).
Just setup the interface to be configured as below:

    IP: 192.168.0.2
    Netmask: 255.255.255.0
    Gateway: 192.168.0.1
    DNS: 8.8.8.8 / 8.8.4.4 (use Google's ones for simplicity)

To confirm that VM (G) is visible to the world with public IP of P run:

    $ curl icanhazip.com

or open [icanhazip.com](http://icanhazip.com/) in the browser.

## Simplifying

You can put commands from steps I, II and III in shell scripts to simplify the
task in case you want to run it frequently. I have made 2 bash scripts.

First on on my local machine (H):

    # vm-tunnel.sh

    $ ssh -o Tunnel=ethernet -w 0:0 root@<P hostname> "~/taptap.sh"
    $ ifconfig tap0 up

Second one on proxy machine (P) in root's home:

    # /root/taptap.sh

    $ echo 1 > /proc/sys/net/ipv4/ip_forward
    $ /usr/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    $ /usr/sbin/iptables -A FORWARD -i eth0 -o tap0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    $ /usr/sbin/iptables -A FORWARD -i tap0 -o eth0 -j ACCEPT

    $ ifconfig tap0 up
    $ ifconfig tap0 192.168.0.1 netmask 255.255.255.0

Thanks to these 2 scripts I can summon my VPN with one command:

    $ sudo vm-tunnel.sh
