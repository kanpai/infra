{ modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  sdImage.compressImage = false;

  # kexec often hangs without this on RPi
  boot.kernelParams = [ "nr_cpus=1" ];
}
