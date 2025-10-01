let
  ski_msung   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0CYZVdkMUezSEsxUpPXIUck+0gmpvA51YmzEjlTbkf";
  ski_msungie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6BOS048/i/K1eGC3chGgLm+qPbFPSI+UvOT09afdTO";
  ski_septs   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuITB/TbH0xxpUCd0Euae8Aom3t20Gv+9KeQOKzpq+3";
  ski_skic    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9GeDZim528MWYXLOJoMUJ4MftXisobAOW+tG/M5XMX";
  tedj_work   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsgGP5uGVZMHbp94rOBg1oRFZyMGHkShO3ER4zjTZhJ";
  tedj_wbus   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ98wrt8I7TtX2MCpkVHamz6MkN749E8Nv4f/6K05eWu";
in {

  "ski_h8c.de/master.age".publicKeys = [ ski_msung tedj_work ];
  "ski_h8c.de/subkey.age".publicKeys = [ ski_msung tedj_work ];
  "ski_h8c.de/revoke.age".publicKeys = [ ski_msung tedj_work ];

  "cal.h8c.de/ski.age".publicKeys = [ ski_msung tedj_work ];

  "arista/wbus_pub.age".publicKeys = [ tedj_wbus ];
  "arista/wbus_sec.age".publicKeys = [ tedj_wbus ];
  "arista/work_cer.age".publicKeys = [ tedj_work ];
  "arista/work_crt.age".publicKeys = [ tedj_work ];
  "arista/work_csr.age".publicKeys = [ tedj_work ];
  "arista/work_pem.age".publicKeys = [ tedj_work ];
  "arista/mailfilters.age".publicKeys = [ tedj_work ];

  "syncthing/ski_msung/config.xml.age".publicKeys = [ ski_msung ];
  "syncthing/ski_msung/cert.pem.age".publicKeys = [ ski_msung ];
  "syncthing/ski_msung/key.pem.age".publicKeys = [ ski_msung ];
  "syncthing/ski_msung/https-cert.pem.age".publicKeys = [ ski_msung ];
  "syncthing/ski_msung/https-key.pem.age".publicKeys = [ ski_msung ];

  "syncthing/ski_msungie/config.xml.age".publicKeys = [ ski_msungie ];
  "syncthing/ski_msungie/cert.pem.age".publicKeys = [ ski_msungie ];
  "syncthing/ski_msungie/key.pem.age".publicKeys = [ ski_msungie ];
  "syncthing/ski_msungie/https-cert.pem.age".publicKeys = [ ski_msungie ];
  "syncthing/ski_msungie/https-key.pem.age".publicKeys = [ ski_msungie ];

  "syncthing/ski_septs/config.xml.age".publicKeys = [ ski_septs ];
  "syncthing/ski_septs/cert.pem.age".publicKeys = [ ski_septs ];
  "syncthing/ski_septs/key.pem.age".publicKeys = [ ski_septs ];
  "syncthing/ski_septs/https-cert.pem.age".publicKeys = [ ski_septs ];
  "syncthing/ski_septs/https-key.pem.age".publicKeys = [ ski_septs ];

  "syncthing/ski_skic/config.xml.age".publicKeys = [ ski_skic ];
  "syncthing/ski_skic/cert.pem.age".publicKeys = [ ski_skic ];
  "syncthing/ski_skic/key.pem.age".publicKeys = [ ski_skic ];
  "syncthing/ski_skic/https-cert.pem.age".publicKeys = [ ski_skic ];
  "syncthing/ski_skic/https-key.pem.age".publicKeys = [ ski_skic ];

  "syncthing/tedj_work/config.xml.age".publicKeys = [ tedj_work ];
  "syncthing/tedj_work/cert.pem.age".publicKeys = [ tedj_work ];
  "syncthing/tedj_work/key.pem.age".publicKeys = [ tedj_work ];
  "syncthing/tedj_work/https-cert.pem.age".publicKeys = [ tedj_work ];
  "syncthing/tedj_work/https-key.pem.age".publicKeys = [ tedj_work ];

}
