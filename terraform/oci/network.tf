 #entire virtual network
resource "oci_core_vcn" "vcn-main" {
  compartment_id = var.tenancy-ocid
  #172.16.0.0 -> 172.15.255.255
  cidr_block = "172.16.0.0/16"
  display_name = "ishtar-edge-vcn"
  dns_label = "ishtaredge"
}

#specific subnet, a smaller slice of VCN's address space
resource "oci_core_subnet" "public" {
  compartment_id = var.tenancy-ocid
  vcn_id = oci_core_vcn.vcn-main.id
  cidr_block = "172.16.1.0/24"
  display_name = "public-subnet"
  dns_label = "main"

  route_table_id = oci_core_route_table.public-net-table.id
}

resource "oci_core_internet_gateway" "vcn-main-gateway" {
  compartment_id = var.tenancy-ocid
  vcn_id = oci_core_vcn.vcn-main.id
  enabled = true
  display_name = "ishtar-edge-internet-gateway"
}

resource "oci_core_route_table" "public-net-table" {
  compartment_id = var.tenancy-ocid
  vcn_id = oci_core_vcn.vcn-main.id

  display_name = "ishtar-edge-public-route-table"

  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.vcn-main-gateway.id
  }
}
