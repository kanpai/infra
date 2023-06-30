{ ... }: {
  system.autoUpgrade = {
    flake = "github:kanpai/infra";
    allowReboot = true;
    dates = "daily";
    rebootWindow = { lower = "02:00"; upper = "05:00"; };
    randomizedDelaySec = "45min";
  };
}
