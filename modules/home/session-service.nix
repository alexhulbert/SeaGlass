serviceName: command: {
  Unit = {
    Description = "${serviceName} Service";
    PartOf = ["graphical-session.target"];
    After = ["graphical-session.target"];
  };
  Install.WantedBy = ["graphical-session.target"];
  Service = {
    Type = "simple";
    Restart = "on-failure";
    Slice = "session-graphical.slice";
    ExecStart = "/usr/bin/env ${command}";
    RestartSec = "1";
  };
}
