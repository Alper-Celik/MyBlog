{
  inputs = {
    theme = { url = "github:serkodev/holy"; flake = false; };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, theme }@inputs:
    flake-utils.lib.eachSystem
      (with flake-utils.lib ;
      [ system.x86_64-linux system.aarch64-linux ])
      (system:
        let
          pkgs = (import nixpkgs) { inherit system; };
        in
        {
          packages =
            let
              blog = pkgs.callPackage ./default.nix { src = self; inherit theme; };
            in
            {
              blog = blog;
              default = blog;
            };
          devshells =
            let
              blog = pkgs.callPackage ./default.nix { src = self; inherit theme; };
            in
            {
              blog = blog;
              default = blog;
            };
        });
}
