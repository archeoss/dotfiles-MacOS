{
  description = "Archeoss nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    spotify-adblock = {
      url = "github:NL-TCH/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };
    doxx = {
      url = "github:archeoss/doxx?ref=fix-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-utils.follows = "lix-module/flake-utils";
    };
  };

  outputs = { self, nix-darwin, nixpkgs, nix-homebrew, spotify-adblock, rust-overlay, lix, lix-module, doxx }@inputs:
  let
    vars = {
      user = "archeoss";
      terminal = "ghostty";
      editor = "nvim";
    };
    configuration = { pkgs, config, ... }: {
      imports = ( import ./modules );

      nixpkgs.overlays = [ rust-overlay.overlays.default ];

      nix.settings.experimental-features = "nix-command flakes";
      nix.settings.ssl-cert-file = "/etc/ssl/certs/ca-certificates.crt";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."ArchMacPro" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit spotify-adblock vars doxx; };
      modules = [ 
        configuration 
        lix-module.nixosModules.default 
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = vars.user;
          };
        }
      ];
    };
  };
}
