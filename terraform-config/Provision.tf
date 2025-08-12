resource "azurerm_resource_group" "p1-rg" {
  name     = "project1-resource-group"
  location = "West Europe"
}

resource "azurerm_virtual_network" "p1-vnet" {
  name                = "project1-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.p1-rg.location
  resource_group_name = azurerm_resource_group.p1-rg.name
}

resource "azurerm_subnet" "sub-net" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.p1-rg.name
  virtual_network_name = azurerm_virtual_network.p1-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "net-inter" {
  name                = "project1-network-interface"
  location            = azurerm_resource_group.p1-rg.location
  resource_group_name = azurerm_resource_group.p1-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-net.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "mk1"
  resource_group_name = azurerm_resource_group.p1-rg.name
  location            = azurerm_resource_group.p1-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.net-inter.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
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
