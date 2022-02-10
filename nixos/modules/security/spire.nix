{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.services.spire-server;

  spireArgs = lib.concatStringsSep " " ([
    "-bindAddress ${cfg.bindAddress}"
    "-dataDir ${cfg.dataDir}"
    "-expandEnv ${toString cfg.expandEnv}"
    "-logFormat ${cfg.logFormat}"
    "-logLevel ${cfg.logLevel}"
    "-serverPort ${toString cfg.serverPort}"
    "-socketPath ${cfg.socketPath}"
    "-trustDomain ${cfg.trustDomain}"
  ] ++ lib.optional (cfg.logFile != null) [
    "-logFile ${cfg.logFile}"
  ]);

in {
  options.services.spire-server = {
    enable = mkEnableOption "Enable spire server";

    package = mkOption {
      type = types.package;
      default = pkgs.spire;
      defaultText = "pkgs.spire";
      description = "Set version of spire-server package to use.";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to hcl configuration file.";
    };

    bindAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "IP address or DNS name of the SPIRE server.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/spire-server";
      description = "Directory to store runtime data.";
    };

    expandEnv = mkOption {
      type = types.bool;
      default = false;
      description = "Expand environment variables in SPIRE config file.";
    };

    logFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Logging file target.";
    };

    logFormat = mkOption {
      type = types.enum [ "text" "json" ];
      default = "text";
      description = "Log format style.";
    };

    logLevel = mkOption {
      type = types.enum [ "debug" "info" "warn" "error" ] ;
      default = "info";
      description = "Logging verbosity.";
    };

    serverPort = mkOption {
      type = types.port;
      default = 8081;
      description = "Port number of the SPIRE server.";
    };

    socketPath = mkOption {
      type = types.path;
      default = "/tmp/spire-server/private/api.sock";
      description = "Path to bind the SPIRE Server API socket.";
    };

    trustDomain = mkOption {
      type = types.nullOr types.str;
      default = null;
      defaultText = "example.org";
      description = "Trust domain.";
    };

  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.spire-server = {
      description = "Spire server daemon";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      serviceConfig = {
        NoNewPrivileges = true;
        DynamicUser = true;
        LogsDirectory = "/var/log/";
        #StateDirectory = "spire-server";
        # According to documentation, the configuration file should be able to hold
        # most configuration values, however, the server will generally not respect them
        # if they have a related explicit argument.
        ExecStart = "${lib.getBin (cfg.package.server or cfg.package)}/bin/spire-server run ${spireArgs} -config ${cfg.configFile}";
        Restart = "on-failure";
        ExecReload = "kill -HUP $MAINPID";
      };
    };

    assertions = [
      {
        assertion = cfg.enable -> cfg.trustDomain != null;
        message = "Please set services.spire-server.trustDomain to a value";
      }
    ];
  };

  meta.maintainers = with lib.maintainers; [ jonringer ];
}
