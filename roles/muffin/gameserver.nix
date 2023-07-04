{ ... }:
{
  services.minecraft-server = {
    enable = true;
    openFirewall = true;
    jvmOpts = builtins.replaceStrings [ "\n" ] [ " " ] ''
      -Xms1024M
      -Xmx8192M
      -XX:+UseG1GC
      -XX:ParallelGCThreads=2
      -XX:MinHeapFreeRatio=5
      -XX:MaxHeapFreeRatio=10
    '';

    eula = true;
    declarative = true;
    serverProperties = {
      max-players = 69;
      motd = "";
      gamemode = 0;
      difficulty = 3;
    };

    mods = [
      "modrinth:fabric-api:0.84.0+1.20.1:sha256-2Pj/rBq8+XKoNpiqagj8S45r664JeHnsUYJbJdxUr2k="
      "modrinth:lithium:mc1.20.1-0.11.2:sha256-oMWVNV1oDgyHv46uuv7f9pANTncajWiU7m0tQ3Tejfk="
      "modrinth:krypton:0.2.3:sha256-aa0YECBs4SGBsbCDZA8ETn4lB4HDbJbGVerDYgkFdpg="
      "modrinth:lazydfu:0.1.3:sha256-Tzt3JztX0Bmo21g3HmPkQmVXwbt8nMEFNqA5chIneMg="
    ];
  };
}
