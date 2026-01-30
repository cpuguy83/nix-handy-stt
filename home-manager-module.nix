{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.handy;
in
{
  options.services.handy = {
    enable = lib.mkEnableOption "Handy speech-to-text application";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The Handy package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
