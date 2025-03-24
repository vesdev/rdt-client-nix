{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    services.rdt-client = {
      enable = mkEnableOption ''
        rdt-client service
      '';

      package = mkOption {
        type = lib.types.package;
        default = pkgs.rdt-client;
      };

      # TODO: make this work
      settings = mkOption {
        type = lib.types.attrs;
        default = {
          Logging = {
            File = {
              Path = "/data/db/rdtclient.log";
              FileSizeLimitBytes = "5242889";
              MaxRollingFiles = "5";
            };
          };
          Database.Path = "/data/db/rdtclient.db";
          Port = 6500;
          BasePath = null;
        };
      };
    };
  };

  config =
    {
      systemd.services.rdt-client = lib.mkIf config.services.rdt-client.enable {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        wants = [ "network-online.target" ];
        restartIfChanged = true;

        serviceConfig =
          {
            user = "rdt-client";
            group = "rdt-client";
            restart = "always";

            ExecStart = "${config.services.rdt-client.package}/bin/RdtClient.Web";
          };
      };
    };
}
