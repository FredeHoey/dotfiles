{ pkgs, config, ... }:let
  glwrap = (package: config.lib.nixGL.wrap package);
in {
  programs.gnome-shell = {
    enable = false; 
  };
  home.packages = (with pkgs.gnomeExtensions; [
        forge
        blur-my-shell
        quick-settings-tweaker
        gsconnect
        user-themes
      ]) ++ (with pkgs; [
        (glwrap gnome-shell)
      ]);
  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "forge@jmmaranan.com"
          "blur-my-shell@aunetx"
          "gsconnect@andyholmes.github.io"
          "quick-settings-tweaks@qwreey"
        ];
      };
      "org/gnome/extensions/forge" = {
        focus-on-hover-enabled = true;
      };

      "org/gnome/desktop/interface" = {
        enable-animations = false;
        show-battery-percentage = true;
        text-scaling-factor = 1.0;
      };

      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = true;
      };
      "org/gnome/mutter".dynamic-workspaces = false;
      "org/gtk/gtk4/settings/file-chooser".show-hidden = true;

      "org/gnome/extensions/forge/keybindings" = {
        window-focus-left = [ "<Super>h" ];
        window-focus-down = [ "<Super>j" ];
        window-focus-up = [ "<Super>k" ];
        window-focus-right = [ "<Super>l" ];

        window-move-left = [ "<Super><Shift>h" ];
        window-move-down = [ "<Super><Shift>j" ];
        window-move-up = [ "<Super><Shift>k" ];
        window-move-right = [ "<Super><Shift>l" ];

        # conflicting default keybinds that I don't need
        con-stacked-layout-toggle = [];
        prefs-tiling-toggle = [];
        window-gap-size-decrease = [];
        window-gap-size-increase = [];
        window-snap-center = [];
        window-snap-one-third-left = [];
        window-snap-one-third-right = [];
        window-snap-two-third-left = [];
        window-snap-two-third-right = [];
        window-swap-last-active = [];
        window-toggle-always-float = ["<Shift><Super>c"];
        window-toggle-float = ["<Super>c"];
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = [ "<Shift><Super>q" ];
        move-to-workspace-1 = [ "<Shift><Super>a" ];
        move-to-workspace-2 = [ "<Shift><Super>s" ];
        move-to-workspace-3 = [ "<Shift><Super>d" ];
        move-to-workspace-4 = [ "<Shift><Super>f" ];
        switch-to-workspace-1 = [ "<Super>a" ];
        switch-to-workspace-2 = [ "<Super>s" ];
        switch-to-workspace-3 = [ "<Super>d" ];
        switch-to-workspace-4 = [ "<Super>f" ];
      };

    };
    # // (
    #   let
    #     custom-bindings = [
    #       {
    #         name = "Launch Terminal";
    #         command = term;
    #         binding = "<Super>Return";
    #       }
    #       {
    #         name = "Launch Browser";
    #         command = browser;
    #         binding = "<Super>b";
    #       }
    #     ];
    #     dconf-bindings = (
    #       builtins.listToAttrs (
    #         lib.lists.imap0 (i: binding: {
    #           name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}/";
    #           value = binding;
    #         }) custom-bindings
    #       )
    #     );
    #   in
    #   dconf-bindings
    #   // {
    #     "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings" =
    #       builtins.attrNames dconf-bindings;
    #   }
    # );
  };
}
