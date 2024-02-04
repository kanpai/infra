{ pkgs, ... }:
let
  domain = "mib.dev";

  src = pkgs.fetchFromGitHub {
    owner = "mibmo";
    repo = "mib.dev";
    rev = "19ede01238458cf60eb117927b497ea315aab08a";
    hash = "sha256-IKjl5VMz5BF0w7SmGdDZ4HyYxuqD8Kw7vdhpgRvtx5E";
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
