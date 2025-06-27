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
  };

  outputs = { self, nix-darwin, nixpkgs, nix-homebrew, spotify-adblock, rust-overlay }@inputs:
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
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."ArchMacPro" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit spotify-adblock vars; };
      modules = [ 
        configuration 
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
