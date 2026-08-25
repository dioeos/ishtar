resource "oci_core_network_security_group" "ishtar-edge-nsg" {
  compartment_id = var.tenancy-ocid
  vcn_id = oci_core_vcn.vcn-main.id

  display_name = "ishtar-edge-nsg"
}

resource "oci_core_network_security_group_security_rule" "wireguard_ingress" {
  network_security_group_id = oci_core_network_security_group.ishtar-edge-nsg.id

  direction = "INGRESS"
  protocol = "17" # UDP
  source = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  udp_options {
    destination_port_range {
      min = 51820
      max = 51820
    }
  }

  description = "Allow WireGuard"
}

resource "oci_core_network_security_group_security_rule" "minecraft_ingress" {
  network_security_group_id = oci_core_network_security_group.ishtar-edge-nsg.id

  direction = "INGRESS"
  protocol = "6" # TCP
  source = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 25565
      max = 25565
    }
  }
}

resource "oci_core_network_security_group_security_rule" "minecraft_simple_voice_chat_ingress" {
  network_security_group_id = oci_core_network_security_group.ishtar-edge-nsg.id

  direction = "INGRESS"
  protocol = "17"
  source = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  udp_options {
    destination_port_range {
      min = 24454
      max = 24454
    }
  }

  description = "Allow Minecraft Simple Voice Chat"
}
