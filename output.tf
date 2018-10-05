
output "boot_ip" {
    value = "${module.boot.privates}"
}

output "master_ip" {
    value = "${module.master.privates}"
}

output "management_ip" {
    value = "${module.management.privates}"
}

output "va_ip" {
    value = "${module.va.privates}"
}

output "worker_ip" {
    value = "${module.worker.privates}"
}
