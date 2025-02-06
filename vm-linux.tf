resource "azurerm_resource_group" "bhmcitrg02" {
  name     = "mcit_resource_group_bh0"
  location = "canadacentral"
}

resource "azurerm_virtual_network" "bhmcitnet02" {
  name                = "braedenmcitnet02"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.bhmcitrg02.location
  resource_group_name = azurerm_resource_group.bhmcitrg02.name
}

resource "azurerm_subnet" "bhmcitsubnet02" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.bhmcitrg02.name
  virtual_network_name = azurerm_virtual_network.bhmcitnet02.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "bhmcitnic02" {
  name                = "linux-nic"
  location            = azurerm_resource_group.bhmcitrg02.location
  resource_group_name = azurerm_resource_group.bhmcitrg02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bhmcitsubnet02.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "bhmcitvmlinux01" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.bhmcitrg02.name
  location            = azurerm_resource_group.bhmcitrg02.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.bhmcitnic02.id,
  ]


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
