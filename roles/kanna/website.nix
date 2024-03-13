{ pkgs, ... }:
let
  domain = "mib.dev";

  src = pkgs.fetchFromGitHub {
    owner = "mibmo";
    repo = "mib.dev";
    rev = "73e1be763b7ad62d76368ecff8ea1e97760bc7c2";
    hash = "sha256-toPUbbp34rWbWDmqJ3XGpUqF8qgj8BST7M/lmAPCb2U=";
  };
in
{
  services.nginx.virtualHosts = {
    "${domain}" = {
      useACMEHost = domain;
      forceSSL = true;
      root = "${src}/www/";
      locations =
        let
          serveFile = file: contentType: {
            extraConfig = "add_header content-type '${contentType}';";
            tryFiles = "/${file} =500";
          };
        in
        {
          "/" = serveFile "main.html" "text/html";
          "=/style" = serveFile "style.css" "text/css";
          "=/gpg.txt" = serveFile "gpg.asc" "text/plain";
          "=/gpg.asc" = serveFile "gpg.asc" "application/octet-stream";
        };
    };
    "www.${domain}" = {
      useACMEHost = domain;
      forceSSL = true;
      locations."/".return = "308 https://${domain}$request_uri";
    };
  };

  security.acme.certs.${domain}.extraDomainNames = [ "www.${domain}" ];
}
