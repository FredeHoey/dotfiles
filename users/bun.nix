{
  pkgs,
  nixgl,
  config,
  ...
}:
let
  browser = "firefox";
  editor = "nvim";
  term = "wezterm";
  launcher = "fuzzel";

  email = "frederikbraendstrup@gmail.com";
  name = "Frede Braendstrup";
  gpg_key = "EEDBC8E8FC8CF68D";

  glwrap = (package: config.lib.nixGL.wrap package);
in
{

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ (final: old: {
      })
    ];
  };
  ai = {
    ollama = {
      host = "0.0.0.0";
      package = glwrap pkgs.ollama;
    };

    enable = true;
  };
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
      firefox.profileNames = ["default"];
      neovim.enable = false;
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

  nixGL.packages = import nixgl { inherit pkgs; };
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

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
        nixgl
      ]) ++ (map glwrap (with pkgs; [
        freecad
        jan
        kicad
      ]));
    file = {
      ".ssh/rc".source = ../extra-config/ssh/rc;

      ".config/wireplumber/wireplumber.conf.d".source = ../extra-config/pipewire;
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
      shellAliases = import ../extra-config/bash/aliases.nix;
      historyControl = [
        "ignoreboth"
        "erasedups"
      ];
      bashrcExtra = ''
        source ${pkgs.fzf}/share/fzf/completion.bash
        source ${../extra-config/bash/bashrc}
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
      tmux.shellIntegrationOptions = [
        "-p"
        "-w"
        "80%"
        "-h"
        "80%"
      ];
    };
    fuzzel.enable = true;
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
    home-manager.enable = true;
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
      search.excludeTags = [
        "trash"
        "spam"
      ];
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
    waybar.enable = true;
    wezterm = {
      enable = true;
      package = glwrap pkgs.wezterm;
      extraConfig = builtins.readFile ../extra-config/wezterm/init.lua;
    };
  };

  wayland.windowManager.sway = import ../modules/sway-config.nix { inherit term browser pkgs launcher; };
  home.stateVersion = "23.11";
}
