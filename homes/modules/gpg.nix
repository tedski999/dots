{ ... }: {
  programs.gpg.enable = true;
  programs.gpg.settings = {
    keyid-format = "LONG";
    with-fingerprint = true;
    with-subkey-fingerprint = true;
    with-keygrip = true;
  };
}
