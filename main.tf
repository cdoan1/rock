module "master" {
  source       = "./modules/pebble"
  type = "master"
  count = 2
}

module "worker" {
  source       = "./modules/pebble"
  type = "worker"
  count = 2
}

module "management" {
  source       = "./modules/pebble"
  type = "management"
  count = 2
}

module "va" {
  source       = "./modules/pebble"
  type = "va"
  count = 2
}

module "boot" {
  source       = "./modules/pebble"
  type = "boot"
  count = 1
}