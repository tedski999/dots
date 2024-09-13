# firefox but worse
{ pkgs, ... }: {

  home.sessionVariables.BROWSER = "chromium";

  programs.chromium.enable = true;
  programs.chromium.package = (pkgs.chromium.override { enableWideVine = true; }).overrideAttrs (old: {
    buildCommand = ''
      ${old.buildCommand}
      wrapProgram "$out"/bin/chromium \
        --set NIXOS_OZONE_WL 1 \
        --set GOOGLE_DEFAULT_CLIENT_ID "77185425430.apps.googleusercontent.com" \
        --set GOOGLE_DEFAULT_CLIENT_SECRET "OTJgUOQcT7lO7GsGZq2G4IlT" \
        --append-flags "--enable-blink-features=MiddleClickAutoscroll"
    '';
  });

  wayland.windowManager.sway.config.keybindings."Mod4+w" = "exec chromium";

}
