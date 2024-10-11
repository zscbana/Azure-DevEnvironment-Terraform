terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.91.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "Terra01-09-RG" {
  name     = "Terra01-09-RG"
  location = "france central"
  tags = {
    env = "dev"
  }
}

resource "azurerm_virtual_network" "Terra01-09-Vnet" {
  name                = "Terra01-09-Vnet"
  resource_group_name = azurerm_resource_group.Terra01-09-RG.name
  location            = azurerm_resource_group.Terra01-09-RG.location
  address_space       = ["192.168.1.0/24"]

  tags = {
    env = "dev"
  }
}

resource "azurerm_subnet" "Main" {
  name                 = "Main"
  resource_group_name  = azurerm_resource_group.Terra01-09-RG.name
  virtual_network_name = azurerm_virtual_network.Terra01-09-Vnet.name
  address_prefixes     = ["192.168.1.0/25"]
}

resource "azurerm_network_security_group" "NSG01" {
  name                = "NSG01-09"
  resource_group_name = azurerm_resource_group.Terra01-09-RG.name
  location            = azurerm_resource_group.Terra01-09-RG.location
  tags = {
    env = "dev"
  }
}

resource "azurerm_network_security_rule" "NSR01" {
  name                        = "NSR01-09"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Terra01-09-RG.name
  network_security_group_name = azurerm_network_security_group.NSG01.name
}

resource "azurerm_subnet_network_security_group_association" "SGA01" {
  subnet_id                 = azurerm_subnet.Main.id
  network_security_group_id = azurerm_network_security_group.NSG01.id
}

resource "azurerm_public_ip" "IP01" {
  name                = "PubIP-01-09"
  resource_group_name = azurerm_resource_group.Terra01-09-RG.name
  location            = azurerm_resource_group.Terra01-09-RG.location
  allocation_method   = "Dynamic"
  tags = {
    env = "dev"
  }
}

resource "azurerm_network_interface" "nic01" {
  name                = "NIC01-09"
  location            = azurerm_resource_group.Terra01-09-RG.location
  resource_group_name = azurerm_resource_group.Terra01-09-RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.IP01.id
  }

  tags = {
    env = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "VM1" {
  name                = "Terr01-09VM"
  resource_group_name = azurerm_resource_group.Terra01-09-RG.name
  location            = azurerm_resource_group.Terra01-09-RG.location
  size                = "Standard_B1ms"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic01.id,
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/Users/omarelbanna/.ssh/vm01_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
