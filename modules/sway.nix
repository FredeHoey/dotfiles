{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    bemenu
    dbus
    glib
    grim
    mako
    slurp
    sway
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

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
}
