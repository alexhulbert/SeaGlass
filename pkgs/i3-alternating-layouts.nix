{ config, lib, pkgs, ... }:

let
  python-pkgs = p: with p; [ i3ipc ];
  python = pkgs.python310.withPackages python-pkgs;
  repo = builtins.fetchTarball {
    url = https://github.com/olemartinorg/i3-alternating-layout/archive/master.tar.gz;
    sha256 = "sha256:0qan85mj8cxdmmiwg8r608zgc6q6k0nq8wy49z3gms9mcdzwx4vp";
  };
in {
  config.systemd.user.services.i3-alternating-layouts = {
    Service = {
      ExecStart = "${python}/bin/python3 ${repo}/alternating_layouts.py";
      Restart = "on-failure";
      Slice = "session.slice";
    };
    Unit = {
      Description = "i3 Alternating Layouts";
      PartOf = [ "graphical-session.target" ];
      Wants = [ "i3.service" ];
    };
  };
}
