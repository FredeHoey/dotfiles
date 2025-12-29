{ pkgs, mod ? "Mod4", term, browser, launcher }:
{
    enable = true;
    systemd.variables = [ "--all" ];
    package = null;
    config = {
      modifier = mod;
      terminal = term;
      input = {
        "type:keyboard" = {
          repeat_delay = "200";
          repeat_rate = "50";
          xkb_options = "caps:escape,compose:app";
        };
      };
      startup = [
        { command = "${pkgs.waybar}/bin/waybar"; }
        { command = "${pkgs.swaybg}/bin/swaybg -i ${../assets/desktop.jpg}"; }
        { command = "${pkgs.mako}/bin/mako --default-timeout 4000"; }
        {
          command =
            "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
        }
      ];
      fonts = {
        names = [ "Iosevka Nerd Font" ];
        style = "Bold Semi";
        size = 10.0;
      };
      keybindings = let 
        screenshot = ''bash -c "mkdir -p ~/screenshots && slurp | grim -g - - | satty --filename - -o ~/screenshots/$(date +%Y_%m_%d_%H_%M_%S).png"'';
      in {
        "${mod}+Shift+q" = "kill";

        "${mod}+Return" = "exec ${term}";
        "${mod}+r" = "exec ${launcher}";
        "${mod}+b" = "exec ${browser}";
        "${mod}+Shift+p" = "exec ${screenshot}";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+g" = "fullscreen toggle";
        "${mod}+t" = "layout toggle split tabbed";

        "${mod}+Shift+Return" = "floating toggle";

        "${mod}+space" = "focus mode_toggle";

        "${mod}+Shift+minus" = "move scratchpad";

        "${mod}+minus" = "scratchpad show";

        "${mod}+a" = "workspace 1";
        "${mod}+s" = "workspace 2";
        "${mod}+d" = "workspace 3";
        "${mod}+f" = "workspace 4";
        "${mod}+z" = "workspace 5";
        "${mod}+x" = "workspace 6";
        "${mod}+c" = "workspace 7";
        "${mod}+v" = "workspace 8";

        "${mod}+Shift+a" = "move container to workspace 1";
        "${mod}+Shift+s" = "move container to workspace 2";
        "${mod}+Shift+d" = "move container to workspace 3";
        "${mod}+Shift+f" = "move container to workspace 4";
        "${mod}+Shift+z" = "move container to workspace 5";
        "${mod}+Shift+x" = "move container to workspace 6";
        "${mod}+Shift+c" = "move container to workspace 7";
        "${mod}+Shift+v" = "move container to workspace 8";

        "${mod}+Shift+e" = "exit";

        "${mod}+y" = "resize shrink width 10 px or 10 ppt";
        "${mod}+u" = "resize grow height 10 px or 10 ppt";
        "${mod}+i" = "resize shrink height 10 px or 10 ppt";
        "${mod}+o" = "resize grow width 10 px or 10 ppt";
      };
      window = {
        border = 1;
        titlebar = false;
      };
      floating = {
        border = 1;
        titlebar = false;
      };
      bars = [ ];
    };

    wrapperFeatures.gtk = true;
  }
