## Setup needed variables

variable "dc" {
    default = "tor01"
}

variable "domain" { default = "example.com" }


variable "ram" {
  description = "8192,16384"
  default     = "16384"
}

variable "vcpu" {
  description = "number of cpu possible values 4, 8, 16"
  default     = "8"
}

variable "proxy" {
  description = "internal ip address of the squid3 proxy to use"
  default     = "10.166.30.141"
}

variable "type" {
    default = "worker"
}
# variable "offline_mode" {}

variable "count" {
    default = 1
}

variable "image_name" {
    default = "REDHAT_7_64"
}

variable "prefix" {
    default = "sre"
}

provider "softlayer" {}

data "template_file" "setup_docker_master" {
  template = "${file("${path.module}/sbin/post-provision.sh")}"
  
  vars {
    proxy = "${var.proxy}"
  }
}

resource "softlayer_virtual_guest" "node" {
  count                = "${var.count}"
  image                = "${var.image_name}"
  name                 = "${var.prefix}-${var.type}-${format("%d",count.index + 1)}"
  domain               = "${var.domain}"
  ssh_keys             = ["922553"]
  region               = "${var.dc}"
  hourly_billing       = true
  private_network_only = false
  cpu                  = "${var.vcpu}"
  ram                  = "${var.ram}"
  disks                = [100]
  local_disk           = false

  provisioner "local-exec" {
    command = "scp ${path.module}/sbin/post-provision.sh root@${self.ipv4_address_private}:/root"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'chmod 755 /root/post-provision.sh'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} '/root/post-provision.sh'"
  }

  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/id_rsa.pub root@${self.ipv4_address_private}:/root/.ssh"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'cd /root/.ssh ; cat id_rsa.pub >> authorized_keys'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} sed -i 's/127.0.1.1/${self.ipv4_address_private}/g' /etc/hosts"
  }
}
