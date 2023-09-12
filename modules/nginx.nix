{ lib, ... }: {
  services.nginx = lib.mkDefault {
    enable = false;
    recommendedProxySettings = true;
    virtualHosts.default = {
      default = true;
      locations."/".return = "444"; # no response
    };
  };
}
