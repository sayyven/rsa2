#Private Endpoints for Applications

resource "azurerm_storage_account" "StorageRSA" {
  name                     = "rsasa2unique123say"
  resource_group_name      = var.rgname
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [ azurerm_resource_group.RG1 ]
}

resource "azurerm_service_plan" "APPSplan" {
  name                = "RSA-app-service-plan"
  location            = var.location
  resource_group_name = var.rgname
   os_type             = "Linux"
  sku_name            = "P1v2"
  depends_on = [ azurerm_storage_account.StorageRSA ]
}
  


resource "azurerm_linux_function_app" "function_app" {
  name                       = "RSA-function-app"
  location                   = var.location
  resource_group_name        = var.rgname
  service_plan_id      = azurerm_service_plan.APPSplan.id
  storage_account_name       = azurerm_storage_account.StorageRSA.name
  storage_account_access_key = azurerm_storage_account.StorageRSA.primary_access_key
  depends_on                 = [azurerm_service_plan.APPSplan]
 
 
  /*app_settings {
    FUNCTIONS_WORKER_RUNTIME = "dotnet-isolated"
  }*/

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet-isolated"
  }

  site_config {
    always_on        = true                 
  ftps_state       = "Disabled" 

   ip_restriction {
    name       = "allow-windows-server"
    ip_address = "10.0.1.5" # Private IP of my Windows Server
    priority   = 100
  }


  ip_restriction {
    name       = "deny-all"
    action     = "Deny" # Deny all other traffic
    priority   = 300
  }



}

}


resource "azurerm_private_endpoint" "function_app_endpoint" {
  name                = "function-app-private-endpoint"
  location            = var.location
  resource_group_name = var.rgname
  subnet_id           = azurerm_subnet.app_subnet.id

  private_service_connection {
    name                           = "function-app-connection"
    private_connection_resource_id = azurerm_linux_function_app.function_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
  depends_on = [ azurerm_service_plan.APPSplan ]
}


#Bastion Host

resource "azurerm_bastion_host" "bastion" {
  name                = "example-bastion"
  location            = var.location
  resource_group_name = var.rgname

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastionIP.id
  }
}

# Windows Virtual Machine
resource "azurerm_network_interface" "vm_nic" {
  name                = "windows-vm-nic"
  location            = var.location
  resource_group_name = var.rgname
  ip_configuration {
    name                          = "vm-ip-configuration"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [ azurerm_bastion_host.bastion ]
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                  = "windows-vm"
  location              = var.location
  resource_group_name   = var.rgname
  size                  = "Standard_D4_v5"
  admin_username        = "azureuser"
  admin_password        = "P@ssword1234!"
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  depends_on = [ azurerm_network_interface.vm_nic ]
}
