{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      # <nixos-hardware/dell/xps/15-9560>
      ./syspkgs.nix
      ./cli.nix
      ./gui.nix
      ./hardware-configuration.nix
      ./home.nix
    ];

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-commmunity/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  boot.cleanTmpDir = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;
  # boot.loader.grub.device = "/dev/sda";

  networking.hostName = "hulbert-nixos";
  networking.networkmanager.enable = true;
  

  time.timeZone = "America/New_York";

  networking.interfaces.enp0s3.useDHCP = true;

  console.font = "Lat2-Terminus16";

  programs.dconf.enable = true;

  services.xserver.enable = true;
  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.bluetooth.enable = true;

  services.xserver.libinput.enable = true;

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

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
  system.stateVersion = "21.05"; # Did you read the comment?

}

