{ lib, ... }: {
  services.nginx = lib.mkDefault {
    enable = false;
    recommendedProxySettings = true;
    appendHttpConfig = ''
      server_names_hash_bucket_size 128;
    '';
    virtualHosts.default = {
      default = true;
      locations."/".return = "444"; # no response
    };
  };
}
