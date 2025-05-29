{ pkgs, ... }: {

  imports = [ ../modules/sway.nix ];

  fonts.packages = [ pkgs.nerd-fonts.iosevka ];

  location = {
    longitude = 10.2;
    latitude = 56.1;
  };

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
    xserver.displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  programs = {
    steam.enable = true;
    wireshark = {
      enable = true;
      usbmon.enable = true;
      dumpcap.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    arandr
    feh
    imagemagick
    libnotify
    mpv
    usbutils
    sddm-chili-theme
    pavucontrol

    gimp
    zathura
    zeal
    xfce.thunar-volman

    discord
    element-desktop
    spotify
    synergy

    freecad
    elmerfem
    gmsh
    calculix
    kicad
    virt-manager

    wireshark
  ];
}
