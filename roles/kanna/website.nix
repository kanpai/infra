{ ... }:
let
  domain = "mib.dev";
  port = 3259;
in
{
  virtualisation.oci-containers.containers.${domain} = {
    image = "ghcr.io/mibmo/mib.dev:19ede01238458cf60eb117927b497ea315aab08a";
    ports = [ "127.0.0.1:${toString port}:3000" ];
  };

  security.acme.certs.${domain}.extraDomainNames = [ "www.${domain}" ];

  services.nginx.virtualHosts = {
    "${domain}" = {
      useACMEHost = domain;
      forceSSL = true;
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:${toString port}$request_uri";
      };
    };
    "www.${domain}" = {
      useACMEHost = domain;
      forceSSL = true;
      locations."/".return = "308 https://${domain}$request_uri";
    };
  };
}
