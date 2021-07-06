⚠ *I have now switched to [i3](https://github.com/vincentbernat/i3wm-configuration).*

# Vincent Bernat's awesome configuration

This is my [awesome](http://awesome.naquadah.org) configuration. It
does not exactly feature the same keybindings as the default
configuration. I don't recommend using it by you can pick anything you
need in it.

This configuration is for _awesome_ 3.4. I did not update to 3.5
yet. Have a look at
[@P-EB pull request](https://github.com/vincentbernat/awesome-configuration/pull/5)
for 3.5 support.

Here some of the things you may be interested in:

 - It is modular. I am using `config` as a table to pass different
   things between "modules".

 - I use a light transparency effect to tell if a window has the focus
   or not. It needs a composite manager.

 - I use a Python script `bin/build-wallpaper` to build the wallpaper
   to be displayed. There is a random selection and it works with
   multihead setup. It seems that classic tools are now able to change
   the wallpaper per screen and therefore, the script may seem a bit
   useless but I keep it.

 - I am using `xss-lock` with `i3lock` as a screensaver. It relies on
   standard X screensaver handling (and therefore is easy for
   application to disable) and also supports systemd
   inhibitors. Nothing fancy but I reuse the wallpaper built above. A
   notification is sent 10 seconds before starting.

 - In `rc/apparance.lua`, you may be interested by the way I configure
   GTK2 and GTK3 to have an unified look. It works and it does not
   need `gnome-control-center`.

 - I have rebuilt my own implementation of the Quake console in
   `lib/quake.lua`. The common ones didn't like when awesome was
   restarted.

 - I am using notifications when changing volume or brightness. I am
   also using notifications to change xrandr setup. This is pretty
   cool.
 
 - Keybindings are "autodocumented". See `lib/keydoc.lua` to see how
   this works. The list of key bindings can be accessed with Mod4 +
   F1.
   
 - On the debug front, I am quite happy with `dbg()` in
   `rc/debug.lua`.
   
 - Many stuff is handled by systemd. The session is still expected to
   be handled by Xsession but we invoke a custom display-specific
   `xsession@.target` which binds to a display-specific
   `graphical-session@.target`. This is different from the
   `graphical-session.target` shipped by distributions because I
   wanted it to be display-specific. Also, unit activation is bundled
   directly into `graphical-session@.target` while dependencies are
   mostly handled in `awesome@.service`.

Also, I am using my custom terminal (`vbeterm`). You need to change
that in `rc.lua`. You can also find the sources on
[GitHub](https://github.com/vincentbernat/vbeterm).

Things in `lib/` are meant to be reused. I am using my own `loadrc()`
function to load modules and therefore, I prefix my modules with
`vbe/`. Before reusing a module, you may want to change this. Another
way to load them is to use:

	require("lib/quake")
	local quake = package.loaded["vbe/quake"]

## Requirements

Required Debian packages to make everything work can be found in my
[Puppet configuration][].

[Puppet configuration]: https://github.com/vincentbernat/puppet-workstation/blob/master/local-modules/desktop/manifests/awesome.pp
