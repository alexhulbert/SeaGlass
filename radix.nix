{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    jdk11 ammonite firecracker
  ];

  virtualisation.docker.enable = true;
  services.logind.extraConfig = "RuntimeDirectorySize=4G";
  boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=0" ];

  networking.nameservers = [ "1.1.1.1" ];
  networking.resolvconf.enable = pkgs.lib.mkForce false;
  services.resolved.enable = true;
  system.nssDatabases.hosts = pkgs.lib.mkForce [ "files" "myhostname" "dns" ];
  environment.etc."resolv.conf".source = pkgs.lib.mkForce (pkgs.writeTextFile {
    name = "resolv.conf";
    text = ''
      nameserver 127.0.0.1
      nameserver 127.0.0.53
      options edns0 trust-ad
      search .
    '';
  });
}

