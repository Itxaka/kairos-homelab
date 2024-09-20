terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "master" {
  name           = "master.qcow2"
  size = 30 * 1024 * 1024 * 1024 # 30 GB
}

resource "libvirt_volume" "worker" {
  count = var.instance_count
  name           = "worker-${count.index}.qcow2"
  size = 20 * 1024 * 1024 * 1024 # 20 GB
}

resource "libvirt_domain" "master" {
  name = "kairos-master"
  cloudinit = libvirt_cloudinit_disk.ccmaster.id
  memory = "16000"
  vcpu   = 8
  machine = "q35"
  firmware = var.firmware
  nvram {
    template = var.nvram_template
    file = "/tmp/custom-vars-master.bin"
  }

  cpu {
    mode = "host-passthrough"
  }

  // This patches the default cdrom devices to be SATA as IDE is not supported under EFI firmware/q35 machine
  xml {
    xslt = file("${path.module}/patch.xsl")
  }


  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk {
    file = var.iso_path
  }

  disk {
    volume_id = libvirt_volume.master.id
  }

  boot_device {
    dev = [ "hd", "cdrom"]
  }


  console {
    type        = "pty"
    target_port = "0"
  }

  tpm {
    backend_type    = "emulator"
    backend_version = "2.0"
  }

  # necessary when using UEFI
  lifecycle {
    ignore_changes = [
      nvram
    ]
  }
}



resource "libvirt_domain" "worker" {
  count = var.instance_count
  name = "kairos-worker-${count.index}"
  cloudinit = libvirt_cloudinit_disk.ccworker[count.index].id
  memory = "16000"
  vcpu   = 8
  machine = "q35"
  firmware = var.firmware
  nvram {
    template = var.nvram_template
    file = "/tmp/custom-vars-worker-${count.index}.bin"
  }

  cpu {
    mode = "host-passthrough"
  }

  // This patches the default cdrom devices to be SATA as IDE is not supported under EFI firmware/q35 machine
  xml {
    xslt = file("${path.module}/patch.xsl")
  }


  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk {
    file = var.iso_path
  }

  disk {
    volume_id = libvirt_volume.worker[count.index].id
  }

  boot_device {
    dev = [ "hd", "cdrom"]
  }


  console {
    type        = "pty"
    target_port = "0"
  }

  tpm {
    backend_type    = "emulator"
    backend_version = "2.0"
  }

  # necessary when using UEFI
  lifecycle {
    ignore_changes = [
      nvram
    ]
  }
}


resource "libvirt_cloudinit_disk" "ccmaster" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data_master.rendered
}

resource "libvirt_cloudinit_disk" "ccworker" {
  count     = var.instance_count
  name      = "ccworker-${count.index}.iso"
  user_data = data.template_file.user_data_worker[count.index].rendered
}

data "template_file" "user_data_master" {
  template = file("${path.module}/cloud_init.yml")
  vars = {
    hostname = "kairos-master"
  }
}

output "instance_ip_addr_master" {
  value = libvirt_domain.master.network_interface.0.addresses.0
}
output "instance_ip_addr_worker" {
  value = libvirt_domain.worker[*].network_interface.0.addresses.0
}

data "template_file" "user_data_worker" {
  count = var.instance_count
  template = file("${path.module}/cloud_init.yml")
  depends_on = [libvirt_domain.master]
  vars = {
    hostname = "kairos-worker-${count.index}"
    network = libvirt_domain.master.network_interface.0.addresses.0
  }
}