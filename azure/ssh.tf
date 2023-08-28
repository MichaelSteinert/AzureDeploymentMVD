resource "random_pet" "mvd_ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource_action" "mvd_ssh_public_key_generator" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.mvd_ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "mvd_ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.mvd_ssh_key_name.id
  location  = azurerm_resource_group.mvd_ressource_group.location
  parent_id = azurerm_resource_group.mvd_ressource_group.id
}

output "public_key_data" {
  value = jsondecode(azapi_resource_action.mvd_ssh_public_key_generator.output).publicKey
}

output "private_key_data" {
  value = jsondecode(azapi_resource_action.mvd_ssh_public_key_generator.output).privateKey
}
