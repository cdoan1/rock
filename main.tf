module "master" {
  source       = "./modules/pebble"
  type         = "master"
  count        = 3
  prefix       = "${var.prefix}"
  dc           = "${var.dc}"
  disk         = [ "100","200" ]
}

module "proxy" {
  source       = "./modules/pebble"
  type = "proxy"
  count = 2
  prefix = "${var.prefix}"
  dc = "${var.dc}"
  disk = [ "100" ]
}

module "worker" {
  source       = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "worker"
  count = 2
  dc = "${var.dc}"
  disk = [ "100" ]
}

module "management" {
  source = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "management"
  vcpu = 8
  ram = 16384
  count = 6
  dc = "${var.dc}"
  disk = [ "100","200" ]
}

module "va" {
  source = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "va"
  count = 3
  vcpu = 8
  ram = 16384
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
  disk = [ "100","200" ]
}

module "haproxy" {
  source = "./modules/haproxy"
  prefix = "${var.prefix}"
  type = "haproxy"
  count = 1
  vcpu = 4
  ram = 8192
  dc = "${var.dc}"
  disk = [ "100" ]

  master_list = "${master_list}"
  proxy_list = "${proxy_list}"
}
