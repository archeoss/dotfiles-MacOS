{ pkgs, config, spotify-adblock, ... }: {
  nixpkgs.config.allowUnfree = true;
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
      qbittorrent 
      raycast
      colima
      bottom
      htop
    ];
  environment.shells = [ pkgs.nushell ];
  
  homebrew = {
    enable = true;
    brews = [
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
