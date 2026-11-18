{
  description = "NixOS configuration for David's laptops";

  # Three laptops, one repo:
  #   maple    Acer Swift 3 (SF314-59), personal
  #   macbook  MacBook Pro 13" 2017 (MacBookPro14,2), personal
  #   work     ThinkPad T14 Gen 7, Famedly
  #
  # Each machine is built from:
  #   modules/common.nix     everything the laptops share
  #   hosts/<name>/          that machine's hardware, disks and extras
  #   home/hosts/<name>.nix  David's home folder on that machine
  #
  # `rebuild` (or nixos-rebuild switch --flake ~/nixos-config --sudo) picks the
  # configuration whose name matches the machine's hostname.

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";   # use the same nixpkgs as the system
    };

    # Ready-made hardware settings for specific laptops (used by macbook and work)
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";   # only used for its own tests; saves a download
    };

    # Declarative disk layout: partitions, encryption and LVM (used by macbook and work)
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Famedly's required settings for work machines (used by work only)
    famedly-nixos = {
      url = "github:famedly/famedly-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      mkHost = name: nixpkgs.lib.nixosSystem {
        # Lets host files use the other inputs, e.g. inputs.nixos-hardware
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            networking.hostName = name;
          }
          ./modules/common.nix
          ./hosts/${name}

          # Home Manager as part of the system: one rebuild updates both
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;      # same packages and allowUnfree as the system
            home-manager.useUserPackages = true;    # user packages install via users.users.david
            home-manager.backupFileExtension = "hm-backup";  # move existing files aside instead of failing
            home-manager.users.david = import ./home/hosts/${name}.nix;
          }
        ];
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs [ "maple" "macbook" "work" ] mkHost;
    };
}
