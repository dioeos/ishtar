provider "oci" {
  tenancy_ocid = var.tenancy-ocid
  user_ocid = var.user-ocid
  private_key_path = var.rsa-private-key-path
  fingerprint = var.fingerprint
  region = var.region
}
