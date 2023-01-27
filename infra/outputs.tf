output "main_nat_ips" {
  description = "List of public IP addresses use for outbound NAT in MAIN"
  value       = google_compute_address.nat.*.address
}

output "dmz_nat_ips" {
  description = "List of public IP addresses use for outbound NAT in DMZ"
  value       = google_compute_address.dmz_nat.*.address
}

output "test_vm" {
  description = "Test VM Name"
  value       = google_compute_instance.test_vm.name
}

# output "multi_ce" {
#   value = module.f5_ce_multi
# }
