resource "random_pet" "mvd_ressource_group_name" {
  prefix = var.mvd_resource_group_name_prefix
}

resource "azurerm_resource_group" "mvd_ressource_group" {
  location = var.resource_group_location
  name     = random_pet.mvd_ressource_group_name.id
}

# Create Virtual Network
resource "azurerm_virtual_network" "mvd_virtual_network" {
  name                = "mvdVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mvd_ressource_group.location
  resource_group_name = azurerm_resource_group.mvd_ressource_group.name
}

# Create Subnet
resource "azurerm_subnet" "mvd_terraform_subnet" {
  name                 = "mvdSubnet"
  resource_group_name  = azurerm_resource_group.mvd_ressource_group.name
  virtual_network_name = azurerm_virtual_network.mvd_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Public IPs
resource "azurerm_public_ip" "mvd_public_ip" {
  name                = "mvdPublicIP"
  location            = azurerm_resource_group.mvd_ressource_group.location
  resource_group_name = azurerm_resource_group.mvd_ressource_group.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and Rule
resource "azurerm_network_security_group" "mvd_network_security_group" {
  name                = "mvdNetworkSecurityGroup"
  location            = azurerm_resource_group.mvd_ressource_group.location
  resource_group_name = azurerm_resource_group.mvd_ressource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Data Dashboard for first Connector
  security_rule {
    name                       = "FirstDataDashboard"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Data Dashboard for second Connector
  security_rule {
    name                       = "SecondDataDashboard"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Data Dashboard for third Connector
  security_rule {
    name                       = "ThirdDataDashboard"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7082"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create Network Interface
resource "azurerm_network_interface" "mvd_network_interface" {
  name                = "mvdNetworkInterface"
  location            = azurerm_resource_group.mvd_ressource_group.location
  resource_group_name = azurerm_resource_group.mvd_ressource_group.name

  ip_configuration {
    name                          = "mvdNetworkInterfaceConfiguration"
    subnet_id                     = azurerm_subnet.mvd_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mvd_public_ip.id
  }
}

# Connect the Security Group to the Network Interface
resource "azurerm_network_interface_security_group_association" "mvd_secruity_group_network_interface" {
  network_interface_id      = azurerm_network_interface.mvd_network_interface.id
  network_security_group_id = azurerm_network_security_group.mvd_network_security_group.id
}

# Generate Random Text for a unique Storage Account Name
resource "random_id" "mvd_random_id" {
  keepers = {
    # Generate a new ID only when a new Resource Group is defined
    resource_group = azurerm_resource_group.mvd_ressource_group.name
  }

  byte_length = 8
}

# Create Storage Account for Boot Diagnostics
resource "azurerm_storage_account" "mvd_storage_account" {
  name                     = "mvddiag${random_id.mvd_random_id.hex}"
  location                 = azurerm_resource_group.mvd_ressource_group.location
  resource_group_name      = azurerm_resource_group.mvd_ressource_group.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create Virtual Machine
resource "azurerm_linux_virtual_machine" "mvd_vm" {
  name                  = "mvdVM"
  location              = azurerm_resource_group.mvd_ressource_group.location
  resource_group_name   = azurerm_resource_group.mvd_ressource_group.name
  network_interface_ids = [azurerm_network_interface.mvd_network_interface.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "mvdOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.mvd_username

  admin_ssh_key {
    username   = var.mvd_username
    public_key = jsondecode(azapi_resource_action.mvd_ssh_public_key_generator.output).publicKey
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mvd_storage_account.primary_blob_endpoint
  }
}
