{ pkgs, ... }: {
  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
	    name = "system-applications";
	    paths = config.environment.systemPackages;
	    pathsToLink = "/Applications";
	  };
  in 
    pkgs.lib.mkForce ''
      # Set up applications
	    echo "setting up /Applications..." >&2
	    rm -rf /Applications/Nix\ Apps
	    mkdir -p /Applications/Nix\ Apps
	    find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
	    while read -r src; do
	      app_name=$(basename "$src")
	      echo "copying $src" >&2
	      ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
	    done
    '';

  system = {
    defaults = {
      dock.autohide = true;
	    dock.persistent-apps = [
	      "${pkgs.obsidian}/Applications/Obsidian.app"
	      "${pkgs.neovide}/Applications/Neovide.app"
	      "${pkgs.telegram-desktop}/Applications/Telegram.app"
	      "/System/Applications/Mail.app"
	      "/Applications/Ghostty.app"
	      "/Applications/Zen.app"
	    ];
	    finder.FXPreferredViewStyle = "clmv";
	    loginwindow.GuestEnabled = false;
	    NSGlobalDomain = {
	      AppleICUForce24HourTime = true;
	      AppleInterfaceStyle = "Dark";
	      KeyRepeat = 2;
	      AppleScrollerPagingBehavior = true;
	      AppleShowAllFiles = true;
	      "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
	    };
	    WindowManager.EnableTiledWindowMargins = false;
	  };
	  keyboard = {
	    enableKeyMapping = true;
	    swapLeftCtrlAndFn = true;
	    remapCapsLockToEscape = true;
	  };
  };
}
