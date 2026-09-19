variable "my_ip_cidr" {
  description = "CIDR allowed to access public EC2 via SSH"
  type        = string
  sensitive   = true
}
