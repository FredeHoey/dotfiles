{ pkgs, config, lib, nixvim,  ... }:
let
  browser = "firefox";
  editor = "nvim";
  term = "foot";

  email = "frederikbraendstrup@gmail.com";
  name = "Frede Braendstrup";
  gpg_key = "EEDBC8E8FC8CF68D";
in {

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ (final: old: {
      })
    ];
  };
  ai.enable = true;
  git-tools.enable = true;

  accounts.email = {
    accounts = {
      bun = {
        realName = name;
        address = email;
        passwordCommand = "${pkgs.rbw}/bin/rbw get gmail-app-password";
        primary = true;
        flavor = "gmail.com";
        folders = {
          inbox = "";
          drafts = "[Gmail]/Drafts";
          sent = "[Gmail]/Sent Mail";
          trash = "[Gmail]/Trash";
        };
        smtp.tls.useStartTls = true;

        gpg = {
          key = gpg_key;
          signByDefault = true;
        };

        imapnotify = {
          enable = true;
          boxes = [ "Inbox" ];
          onNotifyPost = ''
            ${pkgs.libnotify}/bin/notify-send "New mail arrived."
          '';
        };
        notmuch.enable = true;
        neomutt = {
          enable = true;
          mailboxType = "imap";
        };
      };
    };
  };

  stylix = {
    enable = true;
    autoEnable = true;
    
    image = ../assets/desktop.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";

    targets.gnome.enable = true;

    targets = {
      neovim = {
        enable = true;
        plugin = "mini.base16";
      };
      firefox.profileNames = ["default"];
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 32;
    };
    fonts = {
      sizes = {
        applications = 9;
        terminal = 10;
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.nerd-fonts.iosevka;
        name = "Iosevka Nerd Font Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };


  home = {
    username = "bun";
    homeDirectory = "/home/bun";

    sessionVariables = {
      BROWSER = browser;
      EDITOR = editor;
      NIX_SHELL_PRESERVE_PROMPT = "1";
    };

    packages = (with pkgs;
      [
        (callPackage ../packages/tmux-project/default.nix {})

        jq
        fq
        htop
        sqlite
        uv
        cmakeCurses
        ccache
        ninja
        gnumake
        bat
        fd
        ansible
        ripgrep
        yazi
      ]) ++ (with pkgs.gnomeExtensions; [
        forge
        blur-my-shell
        quick-settings-tweaker
        user-themes
      ]);
    file = {
      ".ssh/rc".source = ../configs/ssh/rc;

      ".config/gdb/gdbinit".source = pkgs.writeText "gdbinit" ''
        set auto-load safe-path /
      '';
    };
  };
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
      "org/gnome/desktop/interface".show-battery-percentage = true;
    };
  };
  programs = {
    atuin = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        style = "compact";
        inline_height = 20;
        enter_accept = false;
        keymap_mode = "vim-insert";
      };
      flags = [ "--disable-up-arrow" ];
    };
    bash = {
      enable = true;
      shellAliases = import ../configs/bash/aliases.nix;
      historyControl = [ "ignoreboth" "erasedups" ];
      bashrcExtra = ''
        source ${pkgs.fzf}/share/fzf/completion.bash
        source ${../configs/bash/bashrc}
        if [[ -f ~/.config/work.sh ]]; then
            source ~/.config/work.sh
        fi
      '';
    };
    firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = true;
          settings = {
            "browser.startup.homepage" = "https://qwant.com";
            "browser.search.defaultenginename" = "qwant";
          };
          search = {
            force = true;
            default = "qwant";
            order = [ "qwant" "google" ];
            engines = {
              "nix packages" = {
                urls = [{
                  template = "https://search.nixos.org/packages";
                  params = [
                    { name = "type"; value = "packages"; }
                    { name = "query"; value = "{searchTerms}"; }
                  ];
                }];
                icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };
              "nixoo wiki" = {
                urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
                icon = "https://nixos.wiki/favicon.png";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@nw" ];
              };
              "qwant" = {
                urls = [{ template = "https://www.qwant.com/?q={searchTerms}"; }];
                icon = "https://www.qwant.com/favicon.ico";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@q" ];
              };
              "bing".metaData.hidden = true;
              "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
            };
          };
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            bitwarden
            privacy-badger
            decentraleyes
            qwant-search
          ];
        };
      };
    };
    home-manager.enable = true;
    fzf = {
      enable = true;
      enableBashIntegration = false;
      defaultOptions = [
        "--preview"
        "bat"
        "--bind"
        "ctrl-d:preview-page-down,ctrl-u:preview-page-up"
      ];
      defaultCommand = "fd --type f";
      tmux.enableShellIntegration = true;
      tmux.shellIntegrationOptions = [ "-p" "-w" "80%" "-h" "80%" ];
    };
    git = {
      enable = true;
      difftastic.enable = true;
      extraConfig = {
        user = {
          signingKey = gpg_key;
          inherit email name;
        };
        commit.verbose = true;
        commit.gpgSign = true;
        fetch.parallel = 0;
        pull.rebase = true;
        pull.autoSquash = true;
        pull.autoStash = true;
        push.default = "upstream";
        push.autoSetupRemote = true;
        push.useForceIfIncludes = true;
        rerere.enabled = true;
      };
    };
    neomutt = {
      enable = true;
      settings = {
        sleep_time = "0";
        beep = "no";
        sort = "reverse-date";
      };
      vimKeys = true;
    };
    notmuch = {
      enable = true;
      new.tags = [ "new" ];
      search.excludeTags = [ "trash" "spam" ];
    };
    rbw = {
      enable = true;
      settings = {
        inherit email;
        base_url = "https://bitwarden.fredeb.dev";
        pinentry = pkgs.pinentry-qt;
      };
    };
    readline = {
      enable = true;
      extraConfig = builtins.readFile ../extra-config/readline/readline.conf;
    };
    tmux = {
      enable = true;
      extraConfig = builtins.readFile ../extra-config/tmux/tmux.conf;
      plugins =
        (with import ../modules/tmux.nix { inherit pkgs; }; [ nvim-movement ])
        ++ (with pkgs.tmuxPlugins; [ continuum ]);
    };
    wezterm = {
      enable = true;
      extraConfig = builtins.readFile ../extra-config/wezterm/init.lua;
    };
  };

  wayland.windowManager.sway = let mod = "Mod4";
  in {
    enable = true;
    package = null;
    config = {
      modifier = mod;
      terminal = term;
      input = {
        "type:keyboard" = {
          repeat_delay = "200";
          repeat_rate = "50";
          xkb_options = "caps:escape,compose:ralt";
        };
      };
      startup = [
        { command = "${pkgs.waybar}/bin/waybar"; }
        { command = "${pkgs.swaybg}/bin/swaybg -i ${../assets/desktop.jpg}"; }
        { command = "${pkgs.mako}/bin/mako --default-timeout 4000"; }
        {
          command =
            "${pkgs.wlsunset}/bin/wlsunset -L 10.2 -l 56.2 -t 3200 -T 4500";
        }
        {
          command =
            "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
        }
        # { command = "configure-gtk"; }
      ];
      fonts = {
        names = [ "Iosevka Nerd Font" ];
        style = "Bold Semi";
        size = 10.0;
      };
      keybindings = let 
        lockcmd = "${pkgs.swaylock}/bin/swaylock -f -i ${../assets/desktop.jpg}";
      in {
        "${mod}+Shift+q" = "kill";

        "${mod}+Return" = "exec ${term}";
        "${mod}+r" = "exec fuzzel";
        "${mod}+b" = "exec ${browser}";
        "${mod}+Shift+p" = "exec ${lockcmd}";

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
  };
  home.stateVersion = "23.11";
}
