{ lib, ... }: {
  nix = {
    enable = lib.mkForce true;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than +2";
    };
    settings = {
      auto-optimise-store = true;
    };
  };
}
