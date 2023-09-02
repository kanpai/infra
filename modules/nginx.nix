{ lib, ... }: {
  services.nginx = {
    enable = lib.mkDefault false ;
    recommendedProxySettings = true;
    virtualHosts.default = lib.mkDefault {
      default = true;
      locations."/".return = "444"; # no response
    };
  };
}
