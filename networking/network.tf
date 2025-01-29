resource "azurerm_resource_group" "RG1" {
  name     = var.rgname
  location = var.location
}



resource "azurerm_network_security_group" "NSG1" {
  name                = "NSG1"
  location            = var.location
  resource_group_name = var.rgname
  depends_on = [ azurerm_resource_group.RG1 ]
}



resource "azurerm_virtual_network" "VN1" {
  name                = "VN1"
  location            = var.location
  resource_group_name = var.rgname
  address_space       = ["10.0.0.0/16"]
  depends_on = [ azurerm_network_security_group.NSG1 ]
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "app-subnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.VN1.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [ azurerm_virtual_network.VN1 ]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.VN1.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [ azurerm_virtual_network.VN1 ]
}

resource "azurerm_public_ip" "bastionIP" {
  name                = "BastionIP"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [ azurerm_subnet.bastion_subnet ]
}


#NSG

resource "azurerm_network_security_group" "nsg_apps" {
  name                = "apps-nsg"
  location            = var.location
  resource_group_name = var.rgname
  depends_on = [ azurerm_subnet.app_subnet ]

}

# Allow traffic from Bastion subnet to apps
resource "azurerm_network_security_rule" "allow_bastion_to_apps" {
  resource_group_name = var.rgname
  name                        = "Allow-Bastion-To-Apps"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  network_security_group_name = azurerm_network_security_group.nsg_apps.name
  depends_on = [ azurerm_network_security_group.nsg_apps ]
}

# Deny all other inbound traffic
resource "azurerm_network_security_rule" "deny_all_inbound" {
  resource_group_name = var.rgname
  name                        = "Deny-All-Inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  network_security_group_name = azurerm_network_security_group.nsg_apps.name
  depends_on = [ azurerm_network_security_group.nsg_apps ]
}
# Associate NSG with App Subnet
resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg" {
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_apps.id
  depends_on = [ azurerm_network_security_group.NSG1 ]
}
