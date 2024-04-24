{
  ## description of this package
  description = "Example of a project using nix and riot";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    ## specify any transient dependencies (deps not in nixpkgs) that have nix flakes
    riot = {

      ## there are several valid urls for an input
      url = "github:riot-ml/riot"; # the root of the repo, will take tip of main on first build
      # url = "github:riot-ml/riot/0.0.9"; # tag
      # url = "github:riot-ml/riot/89ab4b9de3f289e36559637deb9ef9d4c0150d7c"; # sha
      # url = "/Users/me/oss/riot-ml/riot"; # local path of the cloned repo

      ## ensure all inputs use same version of nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";

      ## ensure any shared inputs use same version
      ## this does require looking at the inputs section of the flake for each input
      ## e.g. telemetry is an input of riot https://github.com/riot-ml/riot/blob/main/flake.nix#L44
      ## in this case, riot depends on telemetry and this project depends on telemetry
      ## the line below tells riot to use the same version/sha for telemetry as this project
      inputs.telemetry.follows = "telemetry";
    };

    telemetry = {
      url = "github:leostera/telemetry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  ## shouldn't need changes in the next 8 lines
  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inherit (pkgs) ocamlPackages mkShell lib;
        in
          {

            ## it's unlikely devShells will need changes
            devShells = {
              default = mkShell {
                inputsFrom = [
                  ## adds all the propagatedBuildInputs below into the shell
                  self'.packages.default
                ];
                ## buildInputs defines packages you need at dev time, not build time
                buildInputs = with ocamlPackages; [
                  dune_3
                  ocaml
                  utop
                  ocamlformat
                ];
                packages = builtins.attrValues {
                  inherit (ocamlPackages) ocaml-lsp ocamlformat-rpc-lib;
                };
              };
            };
            packages = {
              ## unless this is a monorepo, there's only a single package named "default"
              ## NOTE: the serde flake is a good example of how to build up a monorepo
              ## https://github.com/serde-ml/serde/blob/main/flake.nix
              default = ocamlPackages.buildDunePackage {
                version = "dev";
                ## this needs to match the package name in dune-project
                pname = "nix_riot_example";
                propagatedBuildInputs = with ocamlPackages; [
                  ## for inputs specified above:
                  inputs'.riot.packages.default
                  inputs'.telemetry.packages.default
                  ## For deps in ocamlPackages (the typical case):
                  ## use the same name as in opam/dune-project.
                  ## No versions are specified, the version fetched/built is based on
                  ## the version of nixpkgs specified above.
                  ## You can search on https://search.nixos.org/
                  ## to find the version of odoc in nixpkgs use query ocamlPackages.odoc
                  odoc
                ];
                src = ./.;
              };
            };
          };
    };
}
