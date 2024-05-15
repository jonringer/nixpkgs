{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.obs-studio;
in {
  options.programs.obs-studio = {
    enable = mkEnableOption "OBS Studio program";

    package = mkOption {
      type = types.package;
      default = pkgs.obs-studio;
      defaultText = "pkgs.obs-studio";
      description = "Set obs-studio package to use.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';

    security.polkit.enable = true;
  };

  meta.maintainers = with lib.maintainers; [  ];
}
