resource "azurerm_resource_group" "example" {
  name     = "${var.name_prefix}-${var.simulationclass}-rg"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  
  tags = {
    environment = "gatling_test_${var.simulationclass}"
  }
}

resource "azurerm_container_group" "acs" {
  name                = "${var.name_prefix}-${var.simulationclass}-acs"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  ip_address_type     = "public"
  dns_name_label      = "${var.name_prefix}-${var.simulationclass}"
  os_type             = "Linux"

  container {
    name   = var.simulationclass
    image  = "jibijose/httpbin:version-jdk8-1.0.0"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  tags = {
    environment = "gatling_test_${var.simulationclass}"
    Name = "gatling-cluster-${var.simulationclass}"
  }
}