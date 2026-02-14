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
      default = pkgs.handy-unwrapped;
      defaultText = lib.literalExpression "pkgs.handy-unwrapped";
      description = "The (unwrapped) Handy package to use";
    };

    textInputTool = lib.mkOption {
      type = lib.types.package;
      default = pkgs.wtype;
      defaultText = lib.literalExpression "pkgs.wtype";
      description = "The text input tool to add to PATH (e.g., pkgs.wtype for Wayland, pkgs.xdotool for X11)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.wrapHandy cfg.package cfg.textInputTool) ];
  };
}
