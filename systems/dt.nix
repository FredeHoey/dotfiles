{ pkgs, config, lib, modulesPath, name, ... }: {
  imports = [
    ../common/desktop.nix
    ../modules/default-system-layout.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "amdgpu" "kvm-amd" "wl" "b43" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  environment.variables = { ROC_ENABLE_PRE_VEGA = "1"; };
  hardware.graphics.extraPackages = with pkgs; [ amdvlk rocmPackages.clr.icd ];

  net = {
    enable = true;
    hostname = name;
    lan-interface = "enp39s0";
    wireless-interface = "eth0";
  };

  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    acceleration = "rocm";
    # Run the following command to get a non-comma separated list of
    # nix run nixpkgs#rocmPackages.rocminfo | grep gfx | cut -d "x" -f 2 | head -n 1
    rocmOverrideGfx = "11.0.0";
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
