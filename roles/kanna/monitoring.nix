{ lib, config, ... }:
let
  domain = "monitoring.kanp.ai";

  grafana = config.services.grafana;
  prometheus = config.services.prometheus;
in
{
  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          root_url = "https://${domain}";
          http_addr = "127.0.0.1";
          http_port = 3000;
        };
      };
    };

    prometheus = {
      enable = true;
      scrapeConfigs = [
        {
          job_name = "muffin";
          static_configs = [{
            targets = [ "127.0.0.1:${toString prometheus.exporters.node.port}" ];
          }];
        }
        {
          job_name = "tor";
          static_configs = [{
            targets = [ "127.0.0.1:${toString prometheus.exporters.tor.port}" ];
          }];
        }
      ];
    };

    nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://${toString grafana.settings.server.http_addr}:${toString grafana.settings.server.http_port}";
      };
    };
  };

  persist.directories =
    let
      grafanaDir = lib.optional grafana.enable {
        directory = grafana.dataDir;
        user = "grafana";
        group = "grafana";
      };
      prometheusDir = lib.optional prometheus.enable {
        directory = "/var/lib/${prometheus.stateDir}";
        user = "prometheus";
        group = "prometheus";
      };
    in
    grafanaDir ++ prometheusDir;
}
