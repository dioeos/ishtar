resource "oci_core_instance" "ishtar-edge-nix-instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id = var.tenancy-ocid

  shape = "VM.Standard.A1.Flex"
  shape_config {
    ocpus = 1
    memory_in_gbs = 6
  }
  
  display_name = "ishtar-edge"

  source_details {
    source_type = "image"
    source_id = data.oci_core_images.ubuntu.images[0].id
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id = oci_core_subnet.public.id
  }

  metadata = {
    ssh_authorized_keys = file(var.ishtar-edge-public-key-path)
  }
}
