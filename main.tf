module "master" {
  source       = "./modules/pebble"
  type = "master"
  count = 1
  prefix = "${var.prefix}"
  dc = "${var.dc}"
}

module "worker" {
  source       = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "worker"
  count = 1
  dc = "${var.dc}"
}

module "management" {
  source       = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "management"
  count = 2
  dc = "${var.dc}"
  disk = [ "100","200" ]
}

module "va" {
  source       = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "va"
  count = 1
  dc = "${var.dc}"
}

module "boot" {
  source = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "boot"
  count = 1
  vcpu = 4
  ram = 8192
  dc = "${var.dc}"
}


