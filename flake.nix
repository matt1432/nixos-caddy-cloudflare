{
  description = "Caddy with Cloudflare plugin and expanded module";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = attrs:
      nixpkgs.lib.genAttrs supportedSystems (system:
        attrs (import nixpkgs {inherit system;}));
  in {
    packages = perSystem (pkgs: {
      caddy = pkgs.callPackage ./pkgs {};

      default = self.packages.${pkgs.system}.caddy;
    });

    nixosModules = {
      caddy = import ./modules self nixpkgs;

      default = self.nixosModules.caddy;
    };

    formatter = perSystem (_: pkgs: pkgs.alejandra);

    devShells = perSystem (_: pkgs: {
      update = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          bash
          common-updater-scripts
          git
          go
          jq
          nix-prefetch-git
          nix-prefetch-github
          nix-prefetch-scripts
        ];
      };
    });
  };
}
