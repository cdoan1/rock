output "names" {
    value = "${softlayer_virtual_guest.node.*.name}"
}

output "privates" {
    value = "${softlayer_virtual_guest.node.*.ipv4_address_private}"
}
