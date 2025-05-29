{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    bemenu
    dbus
    glib
    grim
    mako
    slurp
    sway-audio-idle-inhibit
    swaybg
    swayidle
    swaylock
    wayland
    waypipe
    wdisplays
    wl-clipboard
    wlsunset
    xdg-utils
  ];

  programs.sway.enable = true;
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
}
