{ config, pkgs, ... }:
let
  package = pkgs.HentaiAtHome;
  port = 8008;
  dataDir = "/var/lib/private/hentaiathome";
  settings = {
    client = {
      id = "47386";
      keyFile = config.age.secrets.hentaiathome-key.path;
    };
  };
in
{
  systemd.services.hentaiathome = {
    description = "Hentai @ Home";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      DynamicUser = true;
      User = "hentaiathome";
      WorkingDirectory = dataDir;
      StateDirectory = baseNameOf dataDir;
      StateDirectoryMode = "0700";
      ExecStart = with settings.client;
        pkgs.writeShellScript "hentaiathome.sh"
          "${package}/bin/HentaiAtHome <(echo ${id}; cat ${keyFile})";
      RestartSec = 10;
      StartLimitBurst = 5;
      UMask = "077";
      LockPersonality = true;
      #MemoryDenyWriteExecute = true; 
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectProc = "noaccess";
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateUsers = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@resources"
        "~@privileged"
      ];
      CapabilityBoundingSet = [
        "~CAP_SYS_PACCT"
        "~CAP_KILL"
        "~CAP_SYS_TTY_CONFIG"
        "~CAP_SYS_BOOT"
        "~CAP_SYS_CHROOT"
      ];
    };
  };

  age.secrets.hentaiathome-key.file = ../../secrets/hentaiathome-key.age;

  persist.directories = [{
    directory = dataDir;
    user = "hentaiathome";
    group = "hentaiathome";
    mode = "0770";
  }];

  networking.firewall = {
    allowedTCPPorts = [ port ];
    allowedUDPPorts = [ port ];
  };
}
