{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  nix-alien-pkgs = import (
    fetchTarball "https://github.com/thiagokokada/nix-alien/tarball/master"
  ) { };
in
{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/dell/xps/15-9560>
      /home/alex/src/nix-ld/modules/nix-ld.nix
      ./syspkgs.nix
      ./cli.nix
      ./radix.nix
      ./gui.nix
      ./theme.nix
      ./hardware-configuration.nix
      ./home.nix
    ];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  environment.systemPackages = with nix-alien-pkgs; [
    nix-alien
    nix-index-update
  ];

  boot.supportedFilesystems = [ "ntfs" ];
  boot.cleanTmpDir = true;
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 25;
    };
    efi.canTouchEfiVariables = true;
    grub.enable = false;
    timeout = 0;
  };
  boot.kernelPackages = pkgs.linuxPackages_5_19;
  boot.kernelModules = [ "drm_kms_helper" ];
  boot.extraModprobeConfig = "options drm_kms_helper poll=N";
  boot.plymouth.enable = true;

  networking.hostName = "hulbert-nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  networking.interfaces.wlp0s20f3.useDHCP = true;

  programs.dconf.enable = true;

  services.xserver.enable = true;
  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = unstable.pulseaudioFull;
  hardware.bluetooth.enable = true;
  hardware.opengl.enable = true;

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload.enable = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };
  services.xserver.videoDrivers = [ "modesetting" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  services.xserver.libinput.enable = true;
  services.flatpak.enable = true;

  system.activationScripts.binbash = ''
    ln -s /run/current-system/sw/bin/bash /bin/bash 2> /dev/null || true
  '';

  nix.registry."node".to = {
    type = "github";
    owner = "andyrichardson";
    repo = "nix-node";
  };

  users.extraGroups = { wireshark = { gid = 500; }; };
  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "video" "audio" "disk" "libvirtd" "dialout" "wireshark" ];
    shell = pkgs.fish;
  };

  security.sudo.wheelNeedsPassword = false;
  nixpkgs.config.allowUnfree = true;

  services.openssh.enable = true;

  system.autoUpgrade.enable = true;

  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

