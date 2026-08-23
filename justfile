help:
  just --list

sops-update:
  sops updatekeys secrets/ishtar-secrets.yaml

sops-edit:
  EDITOR=vim sops secrets/ishtar-secrets.yaml
