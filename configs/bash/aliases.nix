{
  cp = "cp -i";
  egrep = "egrep --color=auto";
  fgrep = "fgrep --color=auto";
  grep = "grep --color=auto";
  la = "ls -lah";
  ls = "ls --color=auto -FC";
  mv = "mv -i";
  rf = "rm -rf";
  dps = "docker ps -a";
  dcb = "docker compose build --parallel";
  dcu = "docker compose up";
  dcd = "docker compose up -d";
  dck = "docker compose down";
  dr = "docker restart";
  nd = "nix develop";
  z = "zathura";
  venv = ". .venv/bin/activate";
  cdgr = "cd $(git rev-parse --show-toplevel)";
}
