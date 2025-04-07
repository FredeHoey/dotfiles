{ pkgs, ... }: {
  users.users.bun = {
    isNormalUser = true;
    extraGroups =
      [ "wheel" "dialout" "disk" "docker" "video" "wireshark" "uucp" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCz6kfQ3Rka+VXsSSKMG2iAqT36O50kgt2tuzVFQrlw3xrtzRePsS6z0IGu4JjiKfvY7VtOEmuHp1Mu7DR2R4yTs5myhjDF2A2HzM+yiM4lMXNOVFgsr/dDijgNY+kxzujr6mnMA8oACNHht0wuc/ILh0IpUR0x15TO/7szCoRfY4yS7Jp+7d7Xrrz6dFzIisTo81aRiCmAk5KIDO2R+40dPuG0Gl1Ie6T2UqD0FKuCItM22v6omy+B4VhvOya+oMKJ4mJDe2IiDzaIVTrNG0nuUvzUzpzmHFOcq3Q1YBg61fdO7Au10a7N93QLPPkF2dmQYID/vObmwWj8+/PZzhRYIpT7Bo4SwkvmZj11KdPYXxkv+qtfyAFODkUhsoMUfRgxPzqqe0v0CT1jyxSRvBR2xWEIPPGd9ZG1yXv9OmJaFHPyvlq8+mssRTuCYjGONgIa7diGOecnU0UInrGx1z2PsWLvbe+vBBO1HpFGAJmRa5AnCIaGfNFPYP7ophG29zf6LH7hbh2A4Dma2ZNCCL+RLBvc3KXTA8tPQ/EG7SdTWrWBG3c1ZAy+GJu/e0r61cJD9gppXyUGlfUCUqOoyzd9sAuDMFcGu33EM6HbQHwunA9Pi/l0QdbTm0GbsQRDfUNvsEW7VriowahqiBXnCjScdOqJMBh5PH8IX6D/cpUWOQ== cardno:19_936_941"
    ];
  };

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_6_13;
  };

  # Enable networking
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  time.timeZone = "Europe/Copenhagen";

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
    nix-ld.enable = true;
  };

  services = {
    nixseparatedebuginfod.enable = true;
    openssh.enable = true;
    resolved = {
      enable = true;
      dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
      dnsovertls = "true";
    };
    tailscale.enable = true;
    udev = {
      enable = true;
      extraRules = ''
        SUBSYSTEM=="usb", MODE="0660", GROUP="dialout"
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    dconf
    fq
    jq
    git
    gnumake
    htop
    openssl
    python3
    sqlite
  ];

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "C.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  security.pam.services.swaylock.text = "auth include login";

  system.stateVersion = "23.11";
}
