terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.2"
    }
  }
}


variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "8dd1c178-2b25-4878-bd55-9c2ac065d377"
}

resource "random_id" "res_id" {
  byte_length = 8
}

output "rid" {
  value = random_id.res_id.hex
}

/*
Azure IaS
*/
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "tf-rg-${random_id.res_id.hex}"
  location = "eastus2"
}

resource "azurerm_container_registry" "acr" {
  name                = "tfacr${random_id.res_id.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_container_group" "container" {
  name                = "tf-container-${random_id.res_id.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = "Always"
  dns_name_label      = "flask-test-${random_id.res_id.hex}"

  container {
    name   = "tf-container-${random_id.res_id.hex}"
    image  = "${azurerm_container_registry.acr.login_server}/flask-docker:latest"
    cpu    = 1
    memory = 2

    ports {
      port     = 5000
      protocol = "TCP"
    }
  }

  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }

  tags = {
    environment = "dev"
  }
}

output "container_url" {
  value = "http://${azurerm_container_group.container.fqdn}"
}



/* module "app_plan" {
  source = "./core/host/appserviceplan"
  rg_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  resource_token = local.resource_token
/*   tags = azurerm_resource_group.rg.tags */
/*   sku_name = "B1"
  os_type = "Linux" */

/* resource "azurerm_service_plan" "plan" {
  name                = "tf-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "B1"
  os_type  = "Linux"
} */


/* resource "azurerm_linux_web_app" "webapp" {
  name                = "mock-ehr-${random_integer.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      docker_image_name        = "${azurerm_container_registry.acr.login_server}/flask-app:latest"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }


  app_settings = {
    WEBSITES_PORT = "5000"
  }

  identity {
    type = "SystemAssigned"
  }
} */
