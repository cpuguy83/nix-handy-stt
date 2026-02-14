{
  description = "Handy - A free, open source, offline speech-to-text application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    handy = {
      url = "github:cjpais/Handy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      handy,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      wrapHandy =
        pkgs: handy-pkg: textInputTool:
        pkgs.symlinkJoin {
          name = "handy-wrapped";
          paths = [ handy-pkg ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/handy \
              --prefix PATH : "${
                pkgs.lib.makeBinPath [
                  textInputTool
                ]
              }"
          '';
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          wrapped = wrapHandy pkgs handy.packages.${system}.default pkgs.wtype;
        in
        {
          default = wrapped;
          handy = wrapped;
        }
      );

      overlays.default = final: prev: {
        handy = wrapHandy final handy.packages.${final.system}.default final.wtype;
        handy-unwrapped = handy.packages.${final.system}.default;
        wrapHandy = wrapHandy final;
      };

      homeManagerModules = {
        handy = import ./home-manager-module.nix;
        default = self.homeManagerModules.handy;
      };
    };
}
