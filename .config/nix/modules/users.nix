{ pkgs, vars, ... }: {
  system.primaryUser = vars.user;
  
  users = {
    knownUsers = [ vars.user ];
    users.${vars.user} = {
      uid = 501;
      shell = pkgs.fish;
    };
  };

  # Hack to run nushell
  # https://github.com/nix-darwin/nix-darwin/issues/1028
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fish -l -c "nu --config ~/.config/nushell/config.nu --env-config ~/.config/nushell/env.nu"
    '';
  };
}
