let
  domain = "netboot.gsc.io";
in
{ resources, config, options, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;


  systemd.tmpfiles.rules = [
    "d ${config.services.nginx.virtualHosts."${domain}".root} 0755 netboot nginx"
  ];

  networking.firewall.allowedTCPPorts = [
    80 # nginx
    443 # nginx
    61616 # nc/openssl recv from the aarch64 builder
  ];

  users.users.netboot = {
    description = "netboot";
    group = "netboot";
    uid = 406;
    openssh.authorizedKeys.keys = [
      # kif$ vault read -field=public_key ssh-keys/config/ca
      ''cert-authority ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPfNvbD6olP68N7muphzh0hsdNnPfG4LaJvc0oe7D5V8ui54zGvJ4MC6YSwJN6p0pqTOjMBW/fFpsXRuTNon+o1nBaOMU1r9LQM0Y/YKArqVRtDflnOUaz5DUR3Fbg6u8hqpJ92ZSNh0e/QwtE2PD0IzybUlz9SLwBxfkXRG0Hxhtpy7XlS/VqmljFVilI5xRHB91kZRb9mOU7mOx2wwEq5o/8hy3WFcvY9gQkoS0AGJSp4Iyz5VZMRxxsZlchu/RK4efNecfYLmiAYJmSTVngGYBjnzLdW0YISzngQTA8k/z4WDqlCeuxgtAPfnkQECk//X5iDlFjiy1778PngjSuGw4ryOIkmmt0dOqqu58Ua+3N5tNRN5+yTcUeHO955iNLZTFi73Y9khtqQx7+7ckF36cHz7aKD/030KYjYptoUA1+fKs3+kvEZAvybqILNTYmWhPvLwUHXNrsqdSzos4ZRjUgBR2laR6L8x+S+xM+Yu1XT8Uhyti3PV6t4zykUc4Ngi9EWMmGkHMVnwutFJdJymHV0dvdvoA+D2elH2sbEQt7+mIUT06f0dVSHe85vTj56hXGRUqAxur7TM3Ps8Rehk9P89ukP4eicBIte+w4qpoxO+XouCyr3P+v7todrOLno/BQdkAVDl832FPTZA2k/kYCWzd6/jjWu+elswZRyQ==''
    ];
    shell = pkgs.bash;
  };
  users.groups.netboot.gid = 406;

  security.acme = {
    acceptTerms = true;
    email = "graham@grahamc.com";
    certs."${domain}" = {
      keyType = "rsa4096";
      extraLegoRunFlags = [
        # re: https://community.letsencrypt.org/t/production-chain-changes/150739/1
        # re: https://github.com/ipxe/ipxe/pull/116
        # re: https://github.com/ipxe/ipxe/pull/112
        # re: https://lists.ipxe.org/pipermail/ipxe-devel/2020-May/007042.html
        "--preferred-chain"
        "ISRG Root X1"
      ];
      extraLegoRenewFlags = [
        # re: https://community.letsencrypt.org/t/production-chain-changes/150739/1
        # re: https://github.com/ipxe/ipxe/pull/116
        # re: https://github.com/ipxe/ipxe/pull/112
        # re: https://lists.ipxe.org/pipermail/ipxe-devel/2020-May/007042.html
        "--preferred-chain"
        "ISRG Root X1"
      ];
    };
  };

  nix = {
    systemFeatures = [ "kvm" "nixos-test" ];
    package = pkgs.nixUnstable;
  };

  services.nginx = {
    enable = true;
    logError = "stderr debug";
    recommendedTlsSettings = true;
    sslProtocols = "TLSv1.2";
    sslCiphers = "AES256-SHA256";
    virtualHosts = {
      "${domain}" = {
        root = "/var/lib/nginx/netboot/webroot";
        enableACME = true;
        forceSSL = true;
        http2 = false;
      };
    };
  };
}
