{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self
    , flake-parts
    , nixpkgs
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { config
        , pkgs
        , system
        , ...
        }:
        {
          packages = rec {
            rtd-client = pkgs.callPackage ./package.nix { };
            default = rtd-client;
          };
        };

      flake.nixosModules = rec {
        rdt-client = import ./module.nix;
        default = rdt-client;
      };
    };
}

