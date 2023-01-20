output "nat_ips" {
  description = "List of public IP addresses use for outbound NAT"
  value = [
    for ip in google_compute_address.nat : ip.address
  ]
}
