{
  imports = [
    ({
      boot.kernelModules = [ "dm_multipath" "dm_round_robin" "ipmi_watchdog" ];
      services.openssh.enable = true;
    }
    )
    ({
      boot.initrd.availableKernelModules = [
        "ahci"
        "mpt3sas"
        "sd_mod"
        "xhci_pci"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];
      boot.kernelParams = [ "console=ttyS1,115200n8" ];
    }
    )
    ({ lib, ... }:
      {
        boot.loader.grub.extraConfig = ''
          serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
          terminal_output serial console
          terminal_input serial console
        '';
        nix.maxJobs = lib.mkDefault 48;
      }
    )
    ({
      swapDevices = [

        {
          device = "/dev/disk/by-id/ata-MTFDDAV240TDU_21072D79C1B5-part2";
        }

      ];

      fileSystems = {

        "/" = {
          device = "/dev/disk/by-id/ata-MTFDDAV240TDU_21072D79C1B5-part3";
          fsType = "ext4";

        };

      };

      boot.loader.grub.devices = [ "/dev/disk/by-id/ata-MTFDDAV240TDU_21072D79C1B5" ];
    })
    ({ networking.hostId = "f940b022"; }
    )
    ({ modulesPath, ... }: {
      networking.hostName = "netboot-foundation";
      networking.dhcpcd.enable = false;
      networking.defaultGateway = {
        address = "139.178.85.164";
        interface = "bond0";
      };
      networking.defaultGateway6 = {
        address = "2604:1380:4641:c900::8";
        interface = "bond0";
      };
      networking.nameservers = [
        "147.75.207.207"
        "147.75.207.208"
      ];

      networking.bonds.bond0 = {
        driverOptions = {
          mode = "802.3ad";
          xmit_hash_policy = "layer3+4";
          lacp_rate = "fast";
          downdelay = "200";
          miimon = "100";
          updelay = "200";
        };

        interfaces = [
          "enp65s0f0"
          "enp65s0f1"
        ];
      };

      networking.interfaces.bond0 = {
        useDHCP = false;
        macAddress = "40:a6:b7:5f:c0:a0";

        ipv4 = {
          routes = [
            {
              address = "10.0.0.0";
              prefixLength = 8;
              via = "10.70.108.136";
            }
          ];
          addresses = [
            {
              address = "139.178.85.165";
              prefixLength = 31;
            }
            {
              address = "10.70.108.137";
              prefixLength = 31;
            }
          ];
        };

        ipv6 = {
          addresses = [
            {
              address = "2604:1380:4641:c900::9";
              prefixLength = 127;
            }
          ];
        };
      };
    }
    )
  ];
}
