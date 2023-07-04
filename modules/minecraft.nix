{ lib, config, pkgs, ... }:
let
  cfg = config.services.minecraft-server;

  fabric-server =
    let
      inherit (pkgs) stdenv fetchurl makeWrapper jdk;
    in
    { minecraft ? "1.20.1"
    , fabric ? "0.14.21"
    , installer ? "0.11.2"
    , hash ? "sha256-z3k16nO5NDaLhgFL135U+2DiGwocmsabSJwf1OcXsA4="
    }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "fabric-server";
      version = "${minecraft}-${fabric}-${installer}";

      nativeBuildInputs = [ jdk makeWrapper ];

      jar = fetchurl {
        url = "https://meta.fabricmc.net/v2/versions/loader/${minecraft}/${fabric}/${installer}/server/jar";
        inherit hash;
      };

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        makeWrapper ${jdk}/bin/java $out/bin/minecraft-server \
          --append-flags "-jar ${finalAttrs.jar}"
      '';

      meta = with lib; {
        description = "Minecraft server with Fabric modding platform";
        homepage = "https://fabricmc.net/";
        license = licenses.asl20;
        maintainers = with maintainers; [ mib ];
        platforms = platforms.all;
      };
    });

  fetchMod =
    let
      inherit (pkgs) stdenv writeShellScript curl jq;
    in
    args@{ platform, name, version, hash }:
    stdenv.mkDerivation (finalAttrs: {
      pname = name;
      inherit version;

      curl = "${curl}/bin/curl";
      jq = "${jq}/bin/jq";

      builder =
        if platform == "modrinth"
        then
          writeShellScript "fetch-modrinth-${name}-${version}" ''
            ua='User-Agent: kanpai/infra (mib@kanp.ai)'
            api='https://api.modrinth.com/v2/project/${name}/version'

            echo "Calling API endpoint: $api"
            url=$($curl --globoff -H "$ua" "$api" | $jq -r '.[] | select(.version_number == "${version}") | .files[].url')
            echo "Downloading mod: $url"
            $curl --location --url "$url" --output "$out"
          ''
        else abort "unreachable";

      outputHashMode = "flat";
      outputHashAlgo = "sha256";
      outputHash = hash;

      meta = with lib; {
        maintainers = with maintainers; [ mib ];
        platforms = platforms.all;
      };
    });
in
{
  options.services.minecraft-server.mods = with lib;
    let
      strToMod = str:
        let
          # separate string parts
          # follows platform:name:version:hash
          part = n: builtins.elemAt (lib.splitString ":" str) n;
        in
        {
          platform = part 0;
          name = part 1;
          version = part 2;
          hash = part 3;
        };

      modOpts = {
        options = {
          platform = mkOption {
            type = types.enum [ "modrinth" ];
            example = "modrinth";
          };

          name = mkOption {
            type = types.str;
            example = "scroll-for-worldedit";
          };

          version = mkOption {
            type = types.str;
            example = "1.1.3";
          };

          hash = mkOption {
            type = types.str;
            example = "sha256-AAAAAA";
          };
        };
      };
    in
    mkOption {
      type = with types; listOf (coercedTo str strToMod (submodule modOpts));
      default = [ ];
      description = "List of mods to include";
    };

  config = {
    systemd.services.minecraft-server =
      let
        mods = map fetchMod cfg.mods;
        mkModsDir = "mkdir -p ${cfg.dataDir}/mods\n";
        genPath = mod: "${cfg.dataDir}/mods/${baseNameOf mod}}.jar";
      in
      {
        # @TODO: this is very inelegant - especially the mkModsDir
        preStart = lib.mkAfter (mkModsDir + builtins.foldl' (acc: mod: acc + "ln -sf ${mod} ${genPath mod}\n") "" mods);
        postStop = lib.mkBefore (mkModsDir + builtins.foldl' (acc: mod: acc + "unlink ${genPath mod} || true\n") "" mods);
      };

    services.minecraft-server.package = fabric-server { };

    persist.directories = lib.optional cfg.enable {
      directory = cfg.dataDir;
      user = "minecraft";
      group = "minecraft";
    };
  };
}
