output "resource_group_name" {
  value = azurerm_resource_group.mvd_ressource_group.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.mvd_vm.public_ip_address
}
