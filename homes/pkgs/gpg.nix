{ ... }: {

  programs.gpg.enable = true;
  programs.gpg.settings.keyid-format = "LONG";
  programs.gpg.settings.with-fingerprint = true;
  programs.gpg.settings.with-subkey-fingerprint = true;
  programs.gpg.settings.with-keygrip = true;

}
