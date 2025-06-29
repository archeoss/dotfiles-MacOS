{ pkgs, config, lib, ... }: {
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
    # keyboard = {
    #   enableKeyMapping = true;
    #   swapLeftCtrlAndFn = true;
    #   remapCapsLockToEscape = true;
    # };
  };

  launchd.user.agents.UserKeyMappingKbApple.serviceConfig = {
    ProgramArguments =
      let
        matchDevs = {
          ProductID = 0; # 0x0
          VendorID = 0; # 0x0
          Product = "Apple Internal Keyboard / Trackpad";
        };

        propVal.UserKeyMapping =
          let
            # https://developer.apple.com/library/archive/technotes/tn2450/_index.html
            capsLock = 30064771129; # 0x700000039 - USB HID 0x39
            escape = 30064771113; # 0x700000029 - USB HID 0x29
            leftCtrl = 30064771296; # 0x7000000E0 - USB HID 0xE0
            fnGlobe = 1095216660483; # 0xFF00000003 - USB HID (0x0003 + 0xFF00000000 - 0x700000000)
          in
          [
            {
              HIDKeyboardModifierMappingSrc = capsLock;
              HIDKeyboardModifierMappingDst = escape;
            }
            {
              HIDKeyboardModifierMappingSrc = fnGlobe;
              HIDKeyboardModifierMappingDst = leftCtrl;
            }
            {
              HIDKeyboardModifierMappingSrc = leftCtrl;
              HIDKeyboardModifierMappingDst = fnGlobe;
            }
          ];

        toQuotedXML = attrs: lib.escapeXML (builtins.toJSON attrs);
      in
      [
        "/usr/bin/hidutil"
        "property"
        "--match"
        (toQuotedXML matchDevs)
        "--set"
        (toQuotedXML propVal)
      ];
    RunAtLoad = true;
  };
}
