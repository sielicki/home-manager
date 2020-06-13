{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    nixpkgs.overlays = [
      (self: super: rec {
        emacs = pkgs.writeShellScriptBin "dummy-emacs" "" // {
          outPath = "@emacs@";
        };
        emacsPackagesFor = _:
          makeScope super.newScope (_: { emacsWithPackages = _: emacs; });
      })
    ];

    programs.emacs.enable = true;
    services.emacs.enable = true;
    services.emacs.client.enable = true;

    nmt.script = ''
      assertPathNotExists home-files/.config/systemd/user/emacs.socket
      assertFileExists home-files/.config/systemd/user/emacs.service
      assertFileExists home-path/share/applications/emacsclient.desktop

      assertFileContent home-files/.config/systemd/user/emacs.service \
                        ${./emacs-service-emacs.service}
      assertFileContent home-path/share/applications/emacsclient.desktop \
                        ${./emacs-emacsclient.desktop}
    '';
  };
}