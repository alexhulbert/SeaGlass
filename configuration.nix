{ config, pkgs, ... }:

let
  nix-alien-pkgs = import (
    fetchTarball "https://github.com/thiagokokada/nix-alien/tarball/master"
  ) { };
in
{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/dell/xps/15-9560/nvidia>
      <nix-ld/modules/nix-ld.nix>
      ./syspkgs.nix
      ./cli.nix
      ./radix.nix
      ./gui.nix
      ./theme.nix
      ./hardware-configuration.nix
      ./home.nix
    ];

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  nixpkgs.overlays = [(final: prev: {
    nur.repos.crazazy.efm-langserver = prev.nur.repos.crazazy.efm-langserver.overrideAttrs (_: { 
      vendorSha256 = "1i7gfwcgf21vks6c3hif3wav1xmxivnkb1b4blvzmrskk375w018";
    });
  })];

  environment.systemPackages = with nix-alien-pkgs; [
    nix-alien
    nix-index-update
  ];

  boot.supportedFilesystems = [ "ntfs" ];
  boot.cleanTmpDir = true;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub.enable = false;
    timeout = 0;
  };
  boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=0" ]; # for radix
  boot.kernelModules = [ "kvm-intel" "drm_kms_helper" ];
  boot.extraModprobeConfig = "options drm_kms_helper poll=N";
  boot.plymouth.enable = true;


  networking.hostName = "hulbert-nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = [ "127.0.0.1" "1.1.1.1" ]; # for radix
  networking.networkmanager.extraConfig = ''
    [main]
    rc-manager=resolvconf
  '';

  time.timeZone = "America/New_York";

  networking.interfaces.wlp0s20f3.useDHCP = true;

  programs.dconf.enable = true;

  services.logind.extraConfig = "RuntimeDirectorySize=4G";
  services.xserver.enable = true;
  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.bluetooth.enable = true;

  services.xserver.libinput.enable = true;

  # for radix
  system.activationScripts.binbash = ''
    ln -s /run/current-system/sw/bin/bash /bin/bash 2> /dev/null || true
  '';

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "video" "audio" "disk" "libvirtd" ];
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

