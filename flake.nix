{
  description = "NixOS configuration for maple";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";   # use the same nixpkgs as the system
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations.maple = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        # Home Manager as part of the system: one rebuild updates both
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;      # same packages and allowUnfree as the system
          home-manager.useUserPackages = true;    # user packages install via users.users.david
          home-manager.backupFileExtension = "hm-backup";  # move existing files aside instead of failing
          home-manager.users.david = import ./home/david.nix;
        }
      ];
    };
  };
}
