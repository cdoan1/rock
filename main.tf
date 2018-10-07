module "master" {
  source       = "./modules/pebble"
  type = "master"
  count = 1
  prefix = "${var.prefix}"
}

module "worker" {
  source       = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "worker"
  count = 1
}

module "management" {
  source       = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "management"
  count = 2
}

module "va" {
  source       = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "va"
  count = 1
}

module "boot" {
  source = "./modules/pebble"
  prefix = "${var.prefix}"
  type = "boot"
  count = 1
}


