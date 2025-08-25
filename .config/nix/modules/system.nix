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
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    # maxJobs = 4;
    supportedFeatures = [ "kvm" "benchmark" "big-parallel" "nixos-test" ];
    config = {
      virtualisation = {
        # vmVariant = {
        #   virtualisation.qemu.networkingOptions = lib.mkForce [
        #     "-device virtio-net-pci,netdev=user.0"
        #     ''-netdev vmnet-shared,id=user.0,"$QEMU_NET_OPTS"''
        #   ];
        # };
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 24 * 1024;
        };
        cores = 8;
      };
    };
    systems = [ "x86_64-linux" "aarch64-linux" ];
    config.boot.binfmt.emulatedSystems = ["x86_64-linux"];
  };

  nix.settings.trusted-users = [ "archeoss" ];
  # Add needed system-features to the nix daemon
  # Starting with Nix 2.19, this will be automatic
  nix.settings.system-features = [
    "nixos-test"
    "apple-virt"
    "big-parallel"
    "kvm"
  ];
  # nix.settings.trusted-users = [ "root" "@admin" "archeoss" ];
  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };
  services.openssh.enable = true;

  system = {
    defaults = {
      dock = {
        autohide = true;
        showhidden = true; # Translucent.

        mouse-over-hilite-stack = true;

        show-recents = false;
        magnification = false;

        enable-spring-load-actions-on-all-items = true;
        persistent-apps = [
          "${pkgs.obsidian}/Applications/Obsidian.app"
          "${pkgs.neovide}/Applications/Neovide.app"
          "${pkgs.telegram-desktop}/Applications/Telegram.app"
          "/System/Applications/Mail.app"
          "/Applications/Ghostty.app"
          "/Applications/Zen.app"
        ];
      };
      CustomSystemPreferences."com.apple.dock" = {
        autohide-time-modifier    = 0.0;
        autohide-delay            = 0.0;
        expose-animation-duration = 0.0;
        springboard-show-duration = 0.0;
        springboard-hide-duration = 0.0;
        springboard-page-duration = 0.0;
        # Disable hot corners.
        wvous-tl-corner = 0;
        wvous-tr-corner = 0;
        wvous-bl-corner = 0;
        wvous-br-corner = 0;

        launchanim = 0;
      };
      
      loginwindow.GuestEnabled = false;
      NSGlobalDomain = {
        NSDocumentSaveNewDocumentsToCloud = false;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        KeyRepeat = 2;
        AppleScrollerPagingBehavior = true;
        AppleShowAllFiles = true;    
        AppleShowAllExtensions = true;
        "com.apple.springing.enabled" = true;
        "com.apple.springing.delay"   = 0.0;
        "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
      };
      LaunchServices = {
        LSQuarantine = false;
      };
      CustomSystemPreferences."com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
        allowIdentifierForAdvertising     = false;
        forceLimitAdTracking              = true;
        personalizedAdsMigrated           = false;
      };
      WindowManager.EnableTiledWindowMargins = false;

      CustomSystemPreferences."com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores     = true;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles      = true;

        FXEnableExtensionChangeWarning = true;
        FXPreferredViewStyle           = "Nlsv"; # List style.
        FXRemoveOldTrashItems          = true;

        _FXShowPosixPathInTitle      = true;
        _FXSortFoldersFirst          = true;
        _FXSortFoldersFirstOnDesktop = false;

        NewWindowTarget = "Home";

        QuitMenuItem = true; # Allow quitting of Finder application

        ShowExternalHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop     = true;
        ShowPathbar                     = true;
        ShowRemovableMediaOnDesktop     = true;
        ShowStatusBar                   = true;
      };
      screencapture.location = "~/Documents";

    };
    # keyboard = {
    #   enableKeyMapping = true;
    #   swapLeftCtrlAndFn = true;
    #   remapCapsLockToEscape = true;
    # };
  };

  security.pam.services.sudo_local.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  # Broken on 15.6.1 MacOS
  # launchd.user.agents.UserKeyMappingKbApple.serviceConfig = {
  #   ProgramArguments =
  #     let
  #       matchDevs = {
  #         ProductID = 0; # 0x0
  #         VendorID = 0; # 0x0
  #         Product = "Apple Internal Keyboard / Trackpad";
  #       };
  #
  #       propVal.UserKeyMapping =
  #         let
  #           # https://developer.apple.com/library/archive/technotes/tn2450/_index.html
  #           capsLock = 30064771129; # 0x700000039 - USB HID 0x39
  #           escape = 30064771113; # 0x700000029 - USB HID 0x29
  #           leftCtrl = 30064771296; # 0x7000000E0 - USB HID 0xE0
  #           fnGlobe = 1095216660483; # 0xFF00000003 - USB HID (0x0003 + 0xFF00000000 - 0x700000000)
  #         in
  #         [
  #           {
  #             HIDKeyboardModifierMappingSrc = capsLock;
  #             HIDKeyboardModifierMappingDst = escape;
  #           }
  #           {
  #             HIDKeyboardModifierMappingSrc = fnGlobe;
  #             HIDKeyboardModifierMappingDst = leftCtrl;
  #           }
  #           {
  #             HIDKeyboardModifierMappingSrc = leftCtrl;
  #             HIDKeyboardModifierMappingDst = fnGlobe;
  #           }
  #         ];
  #
  #       toQuotedXML = attrs: lib.escapeXML (builtins.toJSON attrs);
  #     in
  #     [
  #       "/usr/bin/hidutil"
  #       "property"
  #       # "--match"
  #       # (toQuotedXML matchDevs)
  #       "--set"
  #       (toQuotedXML propVal)
  #     ];
  #   RunAtLoad = true;
  # };
}
