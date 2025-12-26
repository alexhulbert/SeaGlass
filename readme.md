![Seaglass](https://github.com/user-attachments/assets/73b648ac-fc2d-476d-857f-8ed86da79c96)

![Seaglass2_med](https://github.com/user-attachments/assets/1b25d378-4192-40f8-be32-119d32a715f3)

## What is this repository?

This is a set of declarative Linux configuration files and scripts designed to consistently reproduce my personal setup. It contains many unique features such as:

- A color scheme engine that dynamically themes the entire operating system, including the vast majority of websites and qt/gtk applications
- Global window background translucency effects (without sacrificing the opacity of foreground elements)
- Support for running KDE widgets and services in Hyprland.
- Custom monitor configuration and power widgets
- A modern zsh config with all of the shortcuts and autocomplete features from the fish shell

This repository is designed to provide quick and automatic configuration of all these features on a fresh Arch Linux installation, although configuration for i3 and NixOS is available at an older commit.

Currently, this repository works well, but useful features such as the ones mentioned above are intermingled with various personal configuration changes. These configuration files need to be cleaned up to modularize the various features they provide, but in the meantime, here is a quick summary of how some of the features work:

 <h3>Color Scheme Engine</h3>
 The color scheme engine is implemented with a combination of <a href="https://github.com/dylanaraps/pywal">pywal templates</a>, <a href="https://github.com/luisbocanegra/kde-material-you-colors">kde-material-you-colors</a>, and <a href="https://github.com/alexhulbert/darkreader">a custom fork of the dark reader addon</a>. This fork attaches to a custom native extension that forwards the current pywal color scheme to the addon process. A compiled version of the dark reader fork is available in <a href="user/files/darkreader.xpi">user/files/darkreader.xpi</a> for firefox and <a href="user/files/darkreader-chrome.zip">user/files/darkreader-chrome.zip</a> for Chrome. The associated native extension is available in <a href="user/files/darkreader">user/files/darkreader</a>. Everything else is in <a href="user/firefox.nix">user/firefox.nix</a>.

<h3>Global Transparency</h3>
The OS-wide frosted glass effect is achieved with a combination of <a href="https://github.com/Luwx/Lightly">lightly-qt</a> and <a href="https://github.com/alexhulbert/hyprchroma">a custom Hyprland plugin</a>. This plugin applies a GLSL shader to each window which uses the chromakey algorithm to selectively apply transparency to the system background color and colors close to it. An older commit of this repository contains the necessary configuration to apply a similar effect in i3.

<h3>KDE On Hyprland</h3>
KDE support is achieved by manually starting kde daemon modules via dbus commands and storing windowed versions of plasmoid applets in the hyprland scratchpad. This allows the majority of KDE features to work without having to run plasmashell or use the KDE wayland compositor.

<h3>Automatic Configuration</h3>
The reproducible and declarative aspects of this repository come from its use of <a href="https://github.com/CyberShadow/aconfmgr">aconfmgr</a> and <a href="https://github.com/nix-community/home-manager">nix home-manager</a>. The `system` folder contains the contents of my `~/.config/aconfmgr` folder and the `user` folder contains my `~/.config/home-manager` folder.

# Installation

Since this is a pretty broad repository and different people are likely going to want different things out of it, I've provided multiple installation guides for various parts of the repo.

## Firefox Pywal Customization

I would imagine that most people visiting this repository are primarily interested in the firefox customizations contained within it, and would prefer to apply them as easily as possible to their existing configuration. If you're comfortable using nix home-manager, you can just add <a href="user/firefox.nix">firefox.nix</a> to your home-manager configuration and run `home-manager switch`. If you're not comfortable with home-manager, you can still apply the firefox customization manually.

The following steps should be sufficient to apply the firefox customization to any existing Linux installation, assuming you already have pywal and nodejs installed and working.

1. Put the following content in `~/.mozilla/native-messaging-hosts/darkreader.json`:

```
{
  "name": "darkreader",
  "description": "custom darkreader native host for syncing with pywal",
  "path": "/opt/darkreader-pywal/index.js",
  "type": "stdio",
  "allowed_extensions": ["darkreader@alexhulbert.com"]
}
```

2. Put <a href="user/files/darkreader">these files</a> a new folder called `/opt/darkreader-pywal`. This folder can be put anywhere if you don't have permission to write to `/opt`. Just make sure to update the path in the `path` field in `darkreader.json` to match the location of these files.
3. Set the executable bit on `/opt/darkreader-pywal/index.js` by running `chmod +x /opt/darkreader-pywal/index.js` in a terminal
4. Open firefox and navigate to `about:config` in the URL bar. Set `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`
   > At this point, you can skip steps 5-10 if you have your own userChrome/userContent files that you want to keep.
5. Install pywalfox
6. Download <a href="user/files/theme/firefox/userContent.css">user/files/theme/firefox/userContent.css</a> and place it in `~/.config/wal/templates`
7. Symlink `~/.cache/wal/userContent.css` (create an empty file if it doesn't exist) to `~/.mozilla/Firefox/default/chrome/userContent.css`
8. Put the following content in `~/.mozilla/Firefox/default/chrome/userChrome.css`:

```
@import url('blurredfox/userChrome.css');
@import url('userContent.css');
@import url('layout.css');
```

9. Download <a href="https://github.com/eromatiya/blurredfox">this repo</a> and place the `blurredfox` folder in `~/.mozilla/Firefox/default/chrome`
10. Download <a href="user/files/theme/firefox/twoline.css">user/files/theme/firefox/twoline.css</a> and place it in `~/.mozilla/Firefox/default/chrome`, renaming it from `twoline.css` to `layout.css`
11. Download <a href="user/files/darkreader.xpi">this modified version of the Darkreader addon</a> and install it into firefox, making sure to delete any existing copies of Darkreader
12. Open the dark reader extension, click on "Dev Tools", and then click "Preview new design"
13. Open the dark reader extension again, click "Settings", go to the "Advanced" tab, and enable "Synchronize site fixes"

Close and reopen firefox and the theme should be applied.

For best results, set websites to use their light/default theme in each site's own settings. Darkreader produces much better results when converting light themes and avoids issues like bright borders and inconsistent backgrounds. Also disable the "Detect dark theme" option in Darkreader settings, since Darkreader won't apply any styling (including pywal colors) to pages it detects as already dark.

I'm working on trying to get these changes upstreamed into Darkreader so that the fork isn't necessary.

## Chrome Pywal Customization

The fork also works on Chrome/Chromium/Brave/etc. The steps are slightly different, though.

1. Locate the native extension directory for your browser (on Google Chrome, it would be `~/.config/google-chrome/NativeMessagingHosts`) and create a new file called "darkreader.json" with the following contents:

```
{
  "name": "darkreader",
  "description": "custom darkreader native host for syncing with pywal",
  "path": "/opt/darkreader-pywal/index.js",
  "type": "stdio",
  "allowed_origins": ["chrome-extension://gidgehhdgebooieidpcckaphjbfcghpe/"]
}
```

2. Put <a href="user/files/darkreader">these files</a> a new folder called `/opt/darkreader-pywal` This folder can be put anywhere if you don't have permission to write to `/opt`. Just make sure to update the path in the `path` field in `darkreader.json` to match the location of these files.
3. Set the executable bit on `/opt/darkreader-pywal/index.js` by running `chmod +x /opt/darkreader-pywal/index.js` in a terminal
4. Download <a href="user/files/darkreader-chrome.zip">this modified version of the Darkreader addon</a> and unzip it into a folder anywhere on your computer
5. Open chrome and navigate to `chrome://extensions` in the URL bar. Enable "Developer mode" and click "Load unpacked"
6. Select the directory you unzipped the contents of darkreader-chrome.zip into. You can safely delete the folder after doing this.
7. Open the dark reader extension, click on "Dev Tools", and then click "Preview new design"
8. Open the dark reader extension again, click "Settings", go to the "Advanced" tab, and enable "Synchronize site fixes"
9. Optionally, you can go to the "Appearance" tab in Chrome settings and select "Use GTK" if your GTK theme matches your pywal colors.
10. Follow the tips at the end of the <a href="#firefox-pywal-customization">Firefox section above</a> for best results.

## Background Transparency

Chromakey-based background transparency in hyprland can be achieved by running the following commands:

- `hyprpm add https://github.com/alexhulbert/hyprchroma`
- `hyprpm enable hyprchroma`

To disable chromakey on fullscreen applications, add the following line to your `hyprland.conf`:
`chromakey_enable = fullscreen:0`

Sometimes, videos may be a bit washed out. To set a shortcut key to toggle the chromakey effect, add a line like the following to your `hyprland.conf`:
`bind = $mainMod, O, togglechromakey`

To make the chromakey sync up with your pywal configuration, copy <a href="user/files/theme/colors-hyprland.conf">colors-hyprland.conf</a> to `~/.config/wal/templates` and add the following line to your `hyprland.conf`:
`source = ~/.cache/wal/colors-hyprland.conf`

## Running KDE Applets and Services on Hyprland

The KDE support in hyprland is achieved via a python-based daemon in <a href="user/files/plasma-waybar.py">user/files/plasma-waybar.py</a>. It depends on pyprland, so make sure you've installed that. This daemon should be started with hyprland and will automatically launch any KDE applets specified in `~/.config/hypr/plasmoids.json`. Check <a href="https://github.com/alexhulbert/SeaGlass/blob/41f4feb6c6464ff0a01f3120d92fd5f1f3a4b34e/user/waybar.nix#L9-L52">waybar.nix</a> for an example of how the plasmoids.json file should be formatted (make sure to convert it from nix to json). the `title` property must match the window title of the plasmoid and the `plasmoid` property must match its identifier, which can be found by running `ls /usr/share/plasma/plasmoids`. The `margin_right` property controls how far the applet is from the right edge of the screen.

For each plasmoid added to the plasmoids.json file, three corresponding window rules must be added to your `hyprland.conf` file:

```
windowrulev2 = move 0 -200%,title:^(<TITLE>)$
windowrulev2 = workspace special:scratch_<NAME> silent,title:^(<TITLE>)$
windowrulev2 = size <WIDTH> <HEIGHT>, title:^(<TITLE>)$
```

where `<NAME>` matches the key in the json file and `<TITLE>`, `<WIDTH>`, and `<HEIGHT>` match the corresponding properties for that key.

Then, the on-click events for your waybar modules should be set to run `plasma-waybar toggle <NAME>`, where `<NAME>` is a key in the json file. This assumes plasma-waybar is in your `$PATH`. For an example of all this in action, look at <a href="user/waybar.nix">waybar.nix</a>

KDE also utilizes several services that need to be run in order to function properly. These are loaded in <a href="user/startup.nix">startup.nix</a>. In order to run these services, you'll need to start the kde daemon with hyprland (by adding `kded5` to your `exec-once`). Then, after kded loads, you'll want to run <a href="https://github.com/alexhulbert/SeaGlass/blob/41f4feb6c6464ff0a01f3120d92fd5f1f3a4b34e/user/startup.nix#L96-L107">these shell commands</a>. This will ensure that the wifi and bluetooth applets work properly and that network and storage devices are properly mounted and unmounted. For power management to work properly, you'll need to run `/usr/lib/org_kde_powerdevil` with Hyprland and enable the `power-profiles-daemon` systemd service.

## Theming Applications

This repository also has a custom script that themes gtk and qt applications, as well as spotify and kde plasma.

- If you're running nix home-manager, you can use <a href="user/plasma.nix">theme.nix</a> as a starting point to see how this is done.
- The two main files you'll want to be concerned with are <a href="user/files/theme/seaglass-theme.sh">seaglass-theme.sh</a> and <a href="user/files/theme/seaglass-spicetify.py">seaglass-spicetify.py</a> (for spotify).
- Regardless of whether you're using home-manager, you'll need to install at least `kde-material-you-colors`, `wpgtk`, `lightly-qt`, `python-haishoku`, and `python-pywal`
- If you run into missing dependency issues, you can see the full list of packages I have installed on my laptop by looking at <a href="system/30-pkgs.sh">system/30-pkgs.sh</a>, <a href="system/31-pkgs-cli.sh">system/31-pkgs-cli.sh</a> and <a href="system/32-pkgs-gui.sh">system/32-pkgs-gui.sh</a>.
- You'll also need to make sure the `seaglass-theme` and `seaglass-spicetify` commands are available in your path, and run `seaglass-theme` when your desktop environment loads.
- To use the seaglass kde global theme, put <a href="user/files/theme/kde-theme">the kde-theme folder</a> in `~/.local/share/plasma/look-and-feel` and rename it to "seaglass". This global theme also sets the cursor theme to Bibata, so you might need to install that in order for it to work.

## Fully Installing This Entire Repo

If you'd like to start your linux installation from scratch and use my entire config as a jumping off point, that's possible too. From a freshly bootstrapped Arch installation, follow these steps:

1. Install `paru`, `nix`, and `aconfmgr`
2. Clone this repo to somewhere on your computer
3. Remove configuration that does not apply to you. More information on this can be found below.
4. Symlink the `system` directory of this repo to `~/.config/aconfmgr` and the `user` directory to `~/.config/home-manager`
5. Run `aconfmgr apply`
6. Add nix home-manager channel and the nixpkgs channel
7. Install nix home-manager via nix profile flakes
8. Run `chown -R $USER:$USER /nix` to make the nix store editable by your user
9. Set your name and git information in `user/personal.nix`
10. Run `home-manager switch` to apply the home-manager configuration
11. Run `first-time-setup.sh`
12. Reboot your computer

When I did this most recently, I ran into issues with firefox profiles. The changes to the firefox profile itself are fairly minimal outside of the user chrome stuff, though, so they can easily be applied manually. If you happen to go through this route and encounter any trouble, let me know.

<h3>Removing Irrelevant Configuration</h3>

As stated above, this repository contains my personal dotfiles, including everything from the packages I have installed to laptop-specific adjustments. Below is a non-exhaustive list of sections of this repo which you may want to delete before installing it in totality.

- **xdg-home-cleaner service in `user/startup.nix`**: This makes sure various subfolders of the home directory (including Downloads!) stay deleted
- **`system/33-pkgs-personal.sh`**: This contains software I've installed that most people probably don't also want
- **xdg.userDirs in `user/personal.nix`**: This changes the home directories to be shorter names like "tmp" instead of "Downloads"
- **layout.css override in `user/personal.nix`**: This override hides the firefox url bar unless you focus it by pressing ctrl+L
- **caps.hwdb file in `system/21-gui.sh`**: This remaps the caps lock key to switch back and forth between the last visited workspace
- **copilot key remapping lines in `system/21-gui.sh`**: This remaps the "Copilot Key" on windows laptops to right control
