{ inputs, host }:
final: prev: {
  clamav = inputs.nixpkgs-24_05.legacyPackages.${host.system}.clamav;
}
