// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

# Instance with encryption in transit enabled

resource "oci_core_instance" "test_instance_with_pv_encryption_in_transit" {
  availability_domain = "${data.oci_identity_availability_domain.ad.name}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "TestInstance"
  shape               = "${var.instance_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.test_subnet.id}"
    display_name     = "Primaryvnic"
    assign_public_ip = true
    hostname_label   = "testinstance"
  }

  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.supported_shape_images.images[0], "id")}"
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  timeouts {
    create = "60m"
  }

  is_pv_encryption_in_transit_enabled = "true"
}

resource "oci_core_volume" "test_volume" {
  availability_domain = "${data.oci_identity_availability_domain.ad.name}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "TestVolume"
}

resource "oci_core_volume_attachment" "test_volume_attachment" {
  attachment_type                     = "paravirtualized"
  instance_id                         = "${oci_core_instance.test_instance_with_pv_encryption_in_transit.id}"
  volume_id                           = "${oci_core_volume.test_volume.id}"
  display_name                        = "TestVolumeAttachment"
  is_read_only                        = true
  is_pv_encryption_in_transit_enabled = true
}

# Gets a list of all Oracle Linux 7.5 images that support a given Instance shape
data "oci_core_images" "supported_shape_images" {
  compartment_id   = "${var.tenancy_ocid}"
  shape            = "${var.instance_shape}"
  operating_system = "Oracle Linux"

  filter {
    name   = "launch_options.is_pv_encryption_in_transit_enabled"
    values = ["true"]
  }
}
