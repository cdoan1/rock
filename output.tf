
output "boot_ip" {
    value = "${module.boot.privates}"
}

output "master_ip" {
    value = "${module.master.privates}"
}

output "proxy_ip" {
    value = "${module.proxy.privates}"
}

output "haproxy_public" {
    value = "${module.haproxy.public}"
}
output "haproxy_private" {
    value = "${module.haproxy.privates}"
}

output "master_list" {
    value = "${join(",", module.master.privates)}"
}
output "proxy_list" {
    value = "${join(",", module.proxy.privates)}"
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
