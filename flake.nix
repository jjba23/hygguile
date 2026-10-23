# hygguile

# Copyright © Josep Bigorra <jjbigorra@gmail.com>

# hygguile is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# hygguile is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with hygguile.  If not, see <https://www.gnu.org/licenses/>.

{
  description = "Hygguile - web UI component library for GNU Guile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # guile-uuid has no package in nixpkgs yet, so the branch of this fork that
    # adds one is an input and the overlay below reads the package from it.
    # Drop the input and the overlay together, once that branch is merged and
    # nixos-unstable carries guile-uuid.
    guile-uuid-src = {
      url = "github:jjba23/nixpkgs/guile-uuid-init";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, guile-uuid-src }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            guile-uuid = final.callPackage
              "${guile-uuid-src}/pkgs/by-name/gu/guile-uuid/package.nix" { };
          })
        ];
      };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          guile-hygguile = pkgs.callPackage ./default.nix { };
          default = self.packages.${system}.guile-hygguile;
        });

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.guile-hygguile ];
            packages = with pkgs; [
              guile
              guile-uuid
            ];
            shellHook = ''
              export GUILE_LOAD_PATH="$PWD/src''${GUILE_LOAD_PATH:+:$GUILE_LOAD_PATH}"
            '';
          };
        });
    };
}
