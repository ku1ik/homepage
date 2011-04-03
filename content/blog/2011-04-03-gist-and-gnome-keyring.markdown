title: Github's Gist and Gnome Keyring
date: 2011-04-03 13:20
tags: python, gist, gnome, github

I like to keep my [dotfiles](https://github.com/sickill/dotfiles) in git repository but I never put my `.gitconfig`
there because it included my GitHub API token, that is used for example by _[gist](https://github.com/defunkt/gist)_.
Git allows you to get output of a system commands as values (by prepending value with exclamation mark) for settings
in _[alias]_ section of `.gitconfig` only but I just found out that _gist_ script can also do this trick for
_github.token_ setting. Thanks to that we can prepare some script that gets token from different place, use it
in `.gitconfig`, put config into repository and worry no more about publishing sensitive data.

I put the token in Gnome Keyring as it feels pretty secure. Just go to
_System -> Preferences -> Passwords and Encryption Keys_, press _Ctrl+N_, choose _Stored password_.
Select _login_ keyring, enter "GitHub API Token" as description and your token as password. Now we need
a way to get this token out of keyring in shell script. Fortunately there are python language bindings
for Gnome Keyring.

Python script for retrieving passwords from keyring can look like this:

    #!/usr/bin/env python

    import sys
    import gnomekeyring as gk

    if len(sys.argv) > 2:
        ring_name = sys.argv[2]
    else:
        ring_name = 'login'

    for key in gk.list_item_ids_sync(ring_name):
        item = gk.item_get_info_sync(ring_name, key)
        if item.get_display_name() == sys.argv[1]:
            sys.stdout.write(item.get_secret())
            break

Simple. It prints out password with given name to standard output, without newline character (so it's easier
for other scripts to use it). Let's save it to `~/bin/keyring-get-pass.py` and try it:

    $ python ~/bin/keyring-get-pass.py 'GitHub API Token'
    my-secret-token-i-wont-show-you$

Cool. By default we get secrets from _login_ keyring. This is for convenience as _login_ keyring is being
unlocked at system login time on Gnome (at least on Ubuntu) and it won't ask us to unlock it when running this script.
If we need to get password from different keyring then its name can be passed as the second argument to the script.

Now, let's use the script in `.gitconfig`:

    [github]
      user = sickill
      token = !python ~/bin/keyring-get-pass.py 'GitHub API Token'

If you have other solutions for avoiding publishing passwords and tokens in your dotfiles (like config templates etc)
tell me, I'm eager to hear!
