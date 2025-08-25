{ pkgs, config, spotify-adblock, doxx, ... }: {
  nixpkgs.config.allowUnfree = true;

  # pkgs.doxx-aarch64 = doxx.packages.aarch64-darwin.doxx.overrideAttrs (finalAttrs: oldAttrs: { buildInputs = [ pkgs.apple-sdk_15 ]; });
  environment.systemPackages = with pkgs;
    [ 
      neovim
      mkalias
      obsidian
      telegram-desktop
      mas
      k9s
      bitwarden-desktop
      openvpn
      stow
      delta
      kubectl
      spotify
      spotify-adblock
      youtube-music
      nodejs
      gcc
      go
      rust-bin.stable.latest.default
      bun
      neovide
      nushell
      zoxide
      eza
      ripgrep-all
      ripgrep
      bat
      du-dust
      fastfetch
      starship
      jujutsu
      lazyjj
      fnm
      carapace
      fish
      yaak
      mergiraf
      pueue
      hyperfine
      golangci-lint
      termshark
      vale
      wget
      speedtest-rs
      opencode
      zathura
      vscode
      docker
      docker-compose
      libiconv
      python3
      raycast
      colima
      bottom
      htop
      yubico-pam
      yubikey-manager
      pgadmin4-desktopmode
      tokei
      uv
      helix
      helmfile
      revive
      golangci-lint-langserver
      yt-dlp
      fd
      zellij
      fzf
      xh
      dua
      mprocs
      presenterm
      anki-bin
      devenv
      apple-sdk_15
      doxx.packages.aarch64-darwin.doxx
    ];
      
  environment.shells = [ pkgs.nushell ];
  
  homebrew = {
    enable = true;
    brews = [
      "helm"
      "gemini-cli"
      "dnsmasq"
    ];
    casks = [
      "ghostty"
      "hammerspoon"
      "iina"
      "the-unarchiver"
      "seafile-client"
      "openvpn-connect"
      "phoenix"
      "espanso"
      "legcord"
      "obs"
      "steam"
      "anytype"
      "yubico-authenticator"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    masApps = {
    };
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.hack
  ];
}
