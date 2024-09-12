{ ... }: {

  programs.ssh.enable = true;
  programs.ssh.controlMaster = "auto";
  programs.ssh.controlPersist = "12h";
  programs.ssh.serverAliveCountMax = 3;
  programs.ssh.serverAliveInterval = 5;

}
