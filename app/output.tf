# # +++++++++++++++++++++++++++++++++++++++++++++++ #
# #      VIRTUAL NETWORK                            #
# #                                                 #

# output "virtual_network_name" {
#   value = azurerm_virtual_network.this.name
# }

# output "virtual_network_id" {
#   value = azurerm_virtual_network.this.id
# }

# output "subnets" {
#   value = {
#     # May want to test out a way of grabbing all subnets and stating whether or not they are managed by terraform
#     #
#     for snet in azurerm_subnet.this :
#     snet.name => snet.id
#   }
# }

# output "virtual_network_gateway_ids" {
#   value = {
#     for vgw in azurerm_virtual_network_gateway.this :
#     vgw.name => vgw.id
#   }
# }

# output "virtual_network_gateway_public_ips" {
#   value = {
#     for pip in azurerm_public_ip.vnet_gateway :
#     pip.name => {
#       id         = pip.id
#       ip_address = pip.ip_address
#     }
#   }
# }

# output "firewall_private_ip_addresses" {
#   value = {
#     for fw in azurerm_firewall.this :
#     fw.name => {
#       for ipc in fw.ip_configuration :
#       ipc.name => ipc.private_ip_address
#     }
#   }
# }

# output "route_tables" {
#   value = {
#     for route_table in concat(
#       [for rt in azurerm_route_table.vnet : rt],
#       [for rt in azurerm_route_table.snet : rt]
#     ) :
#     route_table.name => route_table.id
#   }
# }

# #                                                 #
# #      END VIRTUAL NETWORK                        #
# # +++++++++++++++++++++++++++++++++++++++++++++++ #

# # +++++++++++++++++++++++++++++++++++++++++++++++ #
# #      Security Groups                            #
# #                                                 #

# output "application_security_groups" {
#   value = {
#     for asg in azurerm_application_security_group.this :
#     asg.name => asg.id
#   }
#   description = "List of Application Security Groups ids."
# }

# output "network_security_groups" {
#   value = {
#     for nsg in azurerm_network_security_group.this :
#     nsg.name => nsg.id
#   }
#   description = "List of Network Security Group ids."
# }

# output "yaml" {
#   value = local.rule_yaml
#   description = "yaml representing the deployment"
# }

# output "inbound" {
#   value = local.inbound_rule_yaml
#   description = "yaml inculding the inbound rules."
# }

# output "outbound" {
#   value = local.outbound_rule_yaml
#   description = "yaml inculding the outbound rules."
# }

# output "security_group_rules" {
#   value = local.security_group_rules
# }


# output "unique_nsg_refs" {
#   value = local.unique_nsg_refs
# }

# output "unique_nsg_objects" {
#   value = local.unique_nsg_objects
# }

# # output "security_group_rule_loop" {
# #   value = {
# #     for rule in local.security_group_rules :
# #     "${coalesce(try(rule.append, null), false) ? regex(local.nsg_resource_id_regex, rule.network_security_group_id).name : rule.network_security_group_name}::${rule.direction}::${rule.priority}::${rule.name}" => rule
# #   }
# # }

# #                                                 #
# #      END Security Groups                        #
# # +++++++++++++++++++++++++++++++++++++++++++++++ #