locals {
  
  networksecuritygroup_rules = [
    {
        priority= 100
        destination_port_range = 443
        access                      = "Allow"
        protocol                    = "Tcp"
    },

  {
        priority= 200
        destination_port_range =  "*"
        access                      = "Allow"
        protocol                    = "*"
    }
  
   ]
}

/*

locals {
    
    
    rgname = "RSARG"
    location = "East US"

    subnet = [
        {
            name = "subnet1"
            address_prefix = "10.0.0.0/24"

        },

        {
            name = "subnet2"
            address_prefix = "10.0.1.0/24"

        }
    ]
}

*/