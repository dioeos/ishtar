{ pkgs, config, ... }:

let
  waitForTailscale = import ./wait-for-tailscale.nix { inherit pkgs; };
in
{
  sops.secrets.tailscale-auth-key = {};
  services.tailscale = {
    enable = true;

    authKeyFile = config.sops.secrets.tailscale-auth-key.path;
  };
  systemd.services.tailscale-serve = {
  description = "Configure Tailscale Serve routes";

  wantedBy = [ "multi-user.target" ];

  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;

    ExecStartPre = [
      "${waitForTailscale}/bin/wait-for-tailscale"
    ];
  };

  script = ''
    ${pkgs.tailscale}/bin/tailscale serve \
      --https=443 \
      --set-path=/warden \
      --bg \
      http://127.0.0.1:8000

    ${pkgs.tailscale}/bin/tailscale serve \
      --https=443 \
      --set-path=/notes \
      --bg \
      http://127.0.0.1:9000
  '';
};
}
