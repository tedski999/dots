let
  tedj_work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsgGP5uGVZMHbp94rOBg1oRFZyMGHkShO3ER4zjTZhJ";
in {
  "ski_h8c.de.gpg.age".publicKeys = [ tedj_work ];
  "tedj_arista.com.cer.age".publicKeys = [ tedj_work ];
  "tedj_arista.com.crt.age".publicKeys = [ tedj_work ];
  "tedj_arista.com.csr.age".publicKeys = [ tedj_work ];
  "tedj_arista.com.pem.age".publicKeys = [ tedj_work ];
  "syncthing/tedj_work/config.xml.age".publicKeys = [ tedj_work ];
  "syncthing/tedj_work/cert.pem.age".publicKeys = [ tedj_work ];
  "syncthing/tedj_work/key.pem.age".publicKeys = [ tedj_work ];
  "syncthing/tedj_work/https-cert.pem.age".publicKeys = [ tedj_work ];
  "syncthing/tedj_work/https-key.pem.age".publicKeys = [ tedj_work ];
}
