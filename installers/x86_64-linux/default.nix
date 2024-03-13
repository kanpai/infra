{ modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  isoImage = {
    compressImage = false;
    squashfsCompression = "gzip -Xcompression-level 1";
  };
}
