output "acs_id" {
  description = "acs id"
  value       = azurerm_container_group.acs.id
}

output "acs_ip_address" {
  description = "acs ip address"
  value       = azurerm_container_group.acs.ip_address
}

output "acs_fqdn" {
  description = "acs fqdn"
  value       = azurerm_container_group.acs.fqdn
}