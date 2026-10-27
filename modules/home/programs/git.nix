{ pkgs, ... }: let
  shim = import ../system-command.nix { inherit pkgs; };
in {
  programs.git = {
    enable = true;
    package = null;
    settings = {
      init.defaultBranch = "main";
      push = { default = "current"; autoSetupRemote = true; };
      pull.rebase = false;
      rerere.enabled = true;
      alias = {
        dshow = "show --ext-diff";
        dlog = "log -p --ext-diff";
      };
    };
  };
  programs.jujutsu = {
    enable = true;
    package = null;
  };
  programs.difftastic = {
    enable = true;
    package = shim "difft";
    git.enable = true;
    jujutsu.enable = true;
  };
  programs.mergiraf = {
    enable = true;
    package = shim "mergiraf";
    enableGitIntegration = true;
    enableJujutsuIntegration = true;
  };
}
