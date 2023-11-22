{ lib, pkgs, config, ... }:
let
  terraria-config = builtins.toFile "terraria-config" ''
    autocreate=1
    worldname=ooo
    difficulty=2
    maxplayers=8
    port=7777
    upnp=0
    world=${terraria.dataDir}/worlds/ooo.wld
  '';

  terraria = config.services.terraria;
in
{
  services.terraria = {
    enable = false; 
    openFirewall = true;
  };

  systemd.services.terraria.serviceConfig = {
    EnvironmentFile = config.age.secrets.terraria-env.path;
    ExecStart = lib.mkForce ''
      ${lib.getBin pkgs.tmux}/bin/tmux -S ${terraria.dataDir}/terraria.sock new -d ${pkgs.terraria-server}/bin/TerrariaServer \
        -config ${terraria-config} \
        -password $TERRARIA_PASSWORD \
        -motd $TERRARIA_MOTD
    '';
  };

  persist.directories = lib.optional terraria.enable {
    directory = "${terraria.dataDir}/worlds";
    user = "terraria";
    group = "terraria";
  };

  age.secrets = {
    terraria-env.file = ../../secrets/terraria-env.age;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "terraria-server"
  ];

  environment.systemPackages = with pkgs; [
    tmux
  ];
}
