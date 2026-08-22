resource "null_resource" "wait_for_ubuntu" {
  depends_on = [
    oci_core_instance.ishtar-edge-nix-instance
  ]

  provisioner "local-exec" {
    command = <<-EOT
      until ssh \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=5 \
        -i "${var.ishtar-edge-private-key-path}" \
        ubuntu@${oci_core_instance.ishtar-edge-nix-instance.public_ip} \
        'curl -fsIL \
           https://github.com/nix-community/nixos-images/releases/download/nixos-25.11/nixos-kexec-installer-noninteractive-aarch64-linux.tar.gz \
           >/dev/null &&
         sudo -n true'
      do
        sleep 5
      done
    EOT
  }
}

module "system-build" {
  source = "github.com/nix-community/nixos-anywhere//terraform/nix-build"
  attribute = ".#nixosConfigurations.ishtar-edge.config.system.build.toplevel"
}

module "partitioner-build" {
  source = "github.com/nix-community/nixos-anywhere//terraform/nix-build"
  attribute = ".#nixosConfigurations.ishtar-edge.config.system.build.diskoScript"
}

module "install" {
  source = "github.com/nix-community/nixos-anywhere//terraform/install"

  depends_on = [
    null_resource.wait_for_ubuntu
  ]

  nixos_system = module.system-build.result.out
  nixos_partitioner = module.partitioner-build.result.out

  target_host = oci_core_instance.ishtar-edge-nix-instance.public_ip
  instance_id = oci_core_instance.ishtar-edge-nix-instance.id

  target_user = "ubuntu"

  #key of temp ubuntu sys before nixos-anywhere
  ssh_private_key = file(var.ishtar-edge-private-key-path)
}
