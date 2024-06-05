{ lib, pkgs, ... }:
let
  worlds = {
    otherworld = {
      port = 7700;
      players = 2;
      size = "large";
      difficulty = "master";
    };
    ooo = {
      port = 7701;
      players = 2;
      size = "large";
      difficulty = "master";
    };
  };

  containers = map (world: "terraria-${world}") (lib.attrNames worlds);

  stripPrefix = lib.strings.removePrefix "terraria-";
in
{
  environment.systemPackages = [ pkgs.tmux ];
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "terraria-server" ];

  networking.firewall =
    let
      ports = map (world: world.port) (lib.attrValues worlds);
    in
    { allowedTCPPorts = ports; allowedUDPPorts = ports; };

  system.activationScripts.containers-terraria.text =
    lib.strings.concatMapStringsSep
      "\n"
      (container: ''mkdir --parents /persist/containers/${container}/data'')
      containers;

  containers = lib.genAttrs containers (container:
    let
      cfg = worlds.${stripPrefix container};
      serverConfig = builtins.toFile "terraria-config" ''
        upnp=0
        port=${toString cfg.port}
        maxplayers=${toString (cfg.players or 2)}
        ${lib.optionalString (cfg ? "motd") "motd=${cfg.motd}"}
        ${lib.optionalString (cfg ? "password") "password=${cfg.password}"}
        autocreate=${builtins.getAttr (cfg.size or "small") { small = "1"; medium = "2"; large = "3"; }}
        difficulty=${builtins.getAttr (cfg.difficulty or "normal") { normal = "0"; expert = "1"; master= "2"; journey = "3"; }}
        worldname=${stripPrefix container}
        world=/data/worlds/${stripPrefix container}.wld
      '';
    in
    {
      autoStart = true;
      ephemeral = true;
      # preferably use NAT
      #privateNetwork = true;
      bindMounts."/data" = {
        isReadOnly = false;
        hostPath = "/persist/containers/${container}/data";
      };
      config = {
        system = {
          stateVersion = "24.05";
          activationScripts.terraria.text = ''
            mkdir --parents /data
            chown --recursive terraria:terraria /data
          '';
        };
        users = {
          users.terraria = {
            isSystemUser = true;
            group = "terraria";
            home = "/tmp/terraria";
            createHome = true;
          };
          groups.terraria = { };
        };
        networking.firewall = {
          allowedTCPPorts = [ cfg.port ];
          allowedUDPPorts = [ cfg.port ];
        };
        systemd.services.terraria = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          serviceConfig = {
            User = "terraria";
            Group = "terraria";
            Type = "forking";
            GuessMainPID = true;
            UMask = 007;
            ExecStart = ''
              ${lib.getExe pkgs.tmux} -S /data/terraria.sock new -d ${lib.getExe pkgs.terraria-server} -config ${serverConfig}
            '';
            ExecStop = pkgs.writeScript "terraria-stop" ''
              #!${pkgs.runtimeShell}

              if ! [ -d "/proc/$1" ]; then
                exit 0
              fi

              ${lib.getExe pkgs.tmux} -S /data/terraria.sock send-keys Enter exit Enter
              ${lib.getExe' pkgs.coreutils "tail"} --pid="$1" -f /dev/null
              rm /data/terraria.sock
            '';
          };
        };
      };
    });
}
