{ pkgs, config, lib, modulesPath, name, ... }: {
  imports = [
    ../common/desktop.nix
    ../modules/default-system-layout.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "amdgpu" "kvm-amd" ];

  environment.variables = { ROC_ENABLE_PRE_VEGA = "1"; };
  hardware.graphics.extraPackages = with pkgs; [ amdvlk rocmPackages.clr.icd ];
  net = {
    enable = true;
    hostname = name;
    lan-interface = "eno1";
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

  services.udev = {
    enable = true;
    extraRules = ''
      SUBSYSTEM!="block", GOTO="bmaptool_optimizations_end"
      ACTION!="add|change", GOTO="bmaptool_optimizations_end"

      ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="0a5c", ATTRS{idProduct}=="0001", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0a5c", ATTRS{idProduct}=="0001", ATTR{bdi/min_ratio}="0", ATTR{bdi/max_ratio}="1", ATTR{queue/scheduler}="none"

      LABEL="bmaptool_optimizations_end"
    '';
  };
}
