SeaGlass
========

https://github.com/alexhulbert/SeaGlass/assets/2229212/1d0752a5-ae23-4b3b-adb6-9b72af87d5e7

What is this repository?
------------------------

This is a set of declarative Linux configuration files and scripts designed to consistently reproduce my personal setup. It contains many unique features such as:

 - A color scheme engine that dynamically themes the entire operating system, including the vast majority of websites and qt/gtk applications
 - Global window background translucency effects (without sacrificing the opacity of foreground elements)
 - Support for running KDE widgets and services in Hyprland.
 - Custom monitor configuration and power widgets 
 - A modern zsh config with all of the shortcuts and autocomplete features from the fish shell

 This repository is designed to provide quick and automatic configuration of all these features on a fresh Arch Linux installation, although configuration for NixOS is available on an older branch.

 Currently, this repository works, but is in a very WIP state. Useful features such as the ones mentioned above are intermingled with various personal configuration changes. These configuration files need to be cleaned up to modularize the various features they provide, but in the meantime, here is a quick summary of how some of the features works:

 <h3>Color Scheme Engine</h3>
 The color scheme engine is implemented with a combination of <a href="https://github.com/dylanaraps/pywal">pywal templates</a> and <a href="https://github.com/alexhulbert/darkreader">a custom fork of the dark reader addon</a>. This fork attaches to a custom firefox native extension that forwards the current pywal color scheme to the addon process. A compiled version of the dark reader fork is available in <a href="user/resources/darkreader.xpi">user/resources/darkreader.xpi</a> and the associated native extension is available in <a href="user/resources/darkreader">user/resources/darkreader</a>. Everything else is in <a href="user/firefox.nix">user/firefox.nix</a>. When installing the darkreader addon, make sure to enable preview mode, enable automatic updates of the css from GitHub, and turn on browser theming.

<h3>Global Transparency</h3>
The OS-wide frosted glass effect is achieved with a combination of <a href="https://github.com/Luwx/Lightly">lightly-qt</a> and <a href="https://github.com/alexhulbert/hyprchroma">a custom Hyprland plugin</a>. This plugin applies a GLSL shader to each window which uses the chromakey algorithm to selectively apply transparency to the system background color and colors close to it. An older commit of this repository contains the necessary configuration to apply a similar effect in i3.

<h3>KDE On Hyprland</h3>
KDE support is achieved by manually starting kde daemon modules via dbus commands and storing windowed versions of plasmoid applets in the hyprland scratchpad. This allows the majority of KDE features to work without having to run plasmashell or use the KDE wayland compositor.

<h3>Automatic Configuration</h3>
The reproducible and declarative aspects of this repository come from its use of <a href="https://github.com/CyberShadow/aconfmgr">aconfmgr</a> and <a href="https://github.com/nix-community/home-manager">nix home-manager</a>. The `system` folder contains the contents of my `~/.config/aconfmgr` folder and the `user` folder contains my `~/.config/home-manager` folder.



Installation
============

Since this is a pretty broad repository and different people are likely going to want different things out of it, I've provided multiple installation guides for various parts of the repo.

Firefox Pywal Customization
---------------------------

I would imagine that most people visiting this repository are primarily interested in the firefox customizations contained within it, and would prefer to apply them as easily as possible to their existing configuration. If you're comfortable using nix home-manager, you can just add <a href="user/firefox.nix">firefox.nix</a> to your home-manager configuration and run `home-manager switch`. If you're not comfortable with home-manager, you can still apply the firefox customization manually.

The following steps should be sufficient to apply the firefox customization to any existing Linux installation, assuming you already have pywal and nodejs installed and working:

1. Put the following content in `~/.mozilla/native-messaging-hosts/darkreader.json`:
```
{
  "name": "darkreader",
  "description": "custom darkreader native host for syncing with pywal",
  "path": "/opt/darkreader-pywal/index.js",
  "type": "studio",
  "allowed_extensions": ["darkreader@alexhulbert.com"]
}
```
2. Put <a href="user/resources/darkreader">these files</a> a new folder called `/opt/darkreader-pywal`
3. Open firefox and navigate to `about:config` in the URL bar. Set `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`
4. Download <a href="user/resources/theme/firefox/userContent.css">user/resources/theme/firefox/userContent.css</a> and place it in `~/.config/wal/templates`
5. Symlink `~/.cache/wal/userContent.css` (create an empty file if it doesn't exist) to `~/.mozilla/Firefox/default/chrome/userContent.css`
6. Put the following content in `~/.mozilla/Firefox/default/chrome/userChrome.css`:
```
@import url('blurredfox/userChrome.css');
@import url('userContent.css');
@import url('layout.css');
```
7. Download <a href="https://github.com/eromatiya/blurredfox">this repo</a> and place the `blurredfox` folder in `~/.mozilla/Firefox/default/chrome`
8. Download <a href="user/resources/theme/firefox/twoline.css">user/resources/theme/firefox/twoline.css</a> and place it in `~/.mozilla/Firefox/default/chrome`, renaming it from `twoline.css` to `layout.css`
9. Download <a href="user/resources/darkreader.xpi">this modified version of the Darkreader addon</a> and install it into firefox, making sure to delete any existing copies of Darkreader
10. Open the dark reader extension, click on "Dev Tools", and then click "Preview new design"
11. Open the dark reader extension again, click "Settings", go to the "Advanced" tab, and enable "Synchronize site fixes"

Close and reopen firefox and the theme should be applied. Right now the browser chrome doesn't update automatically when the theme changes, but I have a fix for that in the works.

I'm working on trying to get these changes upstreamed into Darkreader so that the fork isn't necessary. These changes should also theoretically work on Chrome, or other chrome-based browsers, but I haven't tried it myself.

Background Transparency
-----------------------

Chromakey-based background transparency in hyprland can be achieved by running the following commands:
- `hyprpm add https://github.com/alexhulbert/HyprChroma`
- `hyprpm enable Hypr-Chroma`

To disable chromakey on fullscreen applications, add the following line to your `hyprland.conf`:
```chromakey_enable = fullscreen:0```

To make the chromakey sync up with your pywal configuration, copy <a href="user/resources/theme/colors-hyprland.conf">colors-hyprland.conf</a> to `~/.config/wal/templates` and add the following line to your `hyprland.conf`:
```source = ~/.cache/wal/colors-hyprland.conf```

Running KDE Applets and Services on Hyprland
--------------------------------------------

The KDE support in hyprland is achieved via a python-based daemon in <a href="user/resources/plasma-waybar.py">user/resources/plasma-waybar.py</a>. It depends on pyprland, so make sure you've installed that. This daemon should be started with hyprland and will automatically launch any KDE applets specified in `~/.config/hypr/plasmoids.json`. Check <a href="https://github.com/alexhulbert/SeaGlass/blob/41f4feb6c6464ff0a01f3120d92fd5f1f3a4b34e/user/waybar.nix#L9-L52">for an example of how the plasmoids.json file should be formatted (make sure to convert it from nix to json). the `title` property must match the window title of the plasmoid and the `plasmoid` property must match its identifier, which can be found by running `ls /usr/share/plasma/plasmoids`. The `margin_right` property controls how far the applet is from the right edge of the screen.

For each plasmoid added to the plasmoids.json file, three corresponding window rules must be added to your `hyprland.conf` file:
```
windowrulev2 = move 0 -200%,title:^(<TITLE>)$
windowrulev2 = workspace special:scratch_<NAME> silent,title:^(<TITLE>)$
windowrulev2 = size <WIDTH> <HEIGHT>, title:^(<TITLE>)$
```
where `<NAME>` matches the key in the json file and `<TITLE>`, `<WIDTH>`, and `<HEIGHT>` match the corresponding properties for that key.

Then, the on-click events for your waybar modules should be set to run `plasma-waybar toggle <NAME>`, where `<NAME>` is a key in the json file. This assumes plasma-waybar is in your `$PATH`. For an example of all this in action, look at <a href="user/waybar.nix">waybar.nix</a>

KDE also utilizes several services that need to be run in order to function properly. These are loaded in <a href="user/startup.nix">startup.nix</a>. In order to run these services, you'll need to start the kde daemon with hyprland (by adding `kded5` to your `exec-once`). Then, after kded loads, you'll want to run <a href="https://github.com/alexhulbert/SeaGlass/blob/41f4feb6c6464ff0a01f3120d92fd5f1f3a4b34e/user/startup.nix#L96-L107">these shell commands</a>. This will ensure that the wifi and bluetooth applets work properly and that network and storage devices are properly mounted and unmounted. For power management to work properly, you'll need to run `/usr/lib/org_kde_powerdevil` with Hyprland and enable the `power-profiles-daemon` systemd service.



Theming Applications
--------------------

This repository also has a custom script that themes gtk and qt applications, as well as spotify and kde plasma.
 - If you're running nix home-manager, you can use <a href="user/plasma.nix">theme.nix</a> as a starting point to see how this is done.
 - The two main files you'll want to be concerned with are <a href="user/resources/theme/seaglass-theme.sh">seaglass-theme.sh</a> and <a href="user/resources/theme/seaglass-spicetify.py">seaglass-spicetify.py</a> (for spotify).
 - Regardless of whether you're using home-manager, you'll need to install at least `kde-material-you-colors`, `wpgtk`, `lightly-qt`, `python-haishoku`, and `python-pywal`
 - If you run into missing dependency issues, you can see the full list of packages I have installed on my laptop by looking at <a href="system/30-pkgs.sh">system/30-pkgs.sh</a>, <a href="system/31-pkgs-cli.sh">system/31-pkgs-cli.sh</a> and <a href="system/32-pkgs-gui.sh">system/32-pkgs-gui.sh</a>.
 - You'll also need to make sure the `seaglass-theme` and `seaglass-spicetify` commands are available in your path, and run `seaglass-theme` when your desktop environment loads.
 - To use the seaglass kde global theme, put <a href="user/resources/theme/kde-theme">the kde-theme folder</a> in `~/.local/share/plasma/look-and-feel` and rename it to "seaglass". This global theme also sets the cursor theme to Bibata, so you might need to install that in order for it to work.

Fully Installing This Entire Repo
---------------------------------

If you'd like to start your linux installation from scratch and use my entire config as a jumping off point, that's possible too. From a freshly bootstrapped Arch installation, follow these steps:

1. Install `paru`, `nix`, and `aconfmgr`
2. Clone this repo to somewhere on your computer
3. Symlink the `system` directory of this repo to `~/.config/aconfmgr` and the `user` directory to `~/.config/home-manager`
4. Run `aconfmgr apply`
5. Add nix home-manager channel and the nixpkgs channel
6. Install nix home-manager via nix profile flakes
7. Run `chown -R $USER:$USER /nix` to make the nix store editable by your user
8. Run `home-manager switch` to apply the home-manager configuration
9. Run `first-time-setup.sh`
10. Reboot your computer

When I did this most recently, I ran into issues with firefox profiles. The changes to the firefox profile itself are fairly minimal outside of the user chrome stuff, though, so they can easily be applied manually. If you happen to go through this route and encounter any trouble, let me know.
