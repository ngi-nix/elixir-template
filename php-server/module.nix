{ config, lib, pkgs, ... }:
with lib;
# TODO: Set to server name, this is where server options are added.
let
  cfg = config.services.server;
in
{
  options.services.hubzilla = {
    enable = mkEnableOption "server";
    home = mkOption {
      type = types.nullOr types.str;
      default = "/var/lib/server";
      description = ''
        Home directory of the
        <literal>server</literal> user
        which contains
        the application's state.
      '';
    };
    database = {
      connection = mkOption {
        type = types.enum [ "mariadb" "pgsql" "mysql" ];
        default = "mysql";
        description = "Database type.";
      };
      name = mkOption {
        type = types.nullOr types.str;
        default = "server";
        description = "Database name.";
      };
      user = mkOption {
        type = types.nullOr types.str;
        default = "server";
        description = "Database user.";
      };
      password = mkOption {
        type = types.nullOr types.str;
        default = "server";
        description = "Database password.";
      };
    };
  };
  config = mkIf cfg.enable {
    # setup server user.
    users.users.server = {
      isSystemUser = true;
      createHome = true;
      home = cfg.home;
      group = "httpd";
    };
    users.groups.httpd = {};
    systemd.services = {
      # setup state directory
      server-setup = {
      wantedBy = [ "multi-user.target" ];
      # We want this before the server is started up.
      before = [ "mysql.service" "httpd.service" ];
      # TODO: Add state script
      script = ''
        # Set stuff up here.
      '';
      serviceConfig = {
          # TODO: Set user to the server's user.
          User = "server";
          Type = "oneshot";
          Group = "httpd";
        };
      };
    };
    # Enable and configure apache.
    services.httpd = {
      enable = true;
      group = "httpd";
      adminAddr = "admin@example.org"; # Email address
      enablePHP = true;
      virtualHosts = {
        localhost = {
          extraConfig = ''
            DirectoryIndex index.php index.phtml index.html index.htm
          '';
          documentRoot = "/var/lib/server"; # TODO: Rename
        };
      };
    };
  };
}