output "ad_bastion_hostname" {
    value = aws_instance.windows[0].public_dns
}

output "ad_bastion_private_ip" {
    value = aws_instance.windows[0].private_ip
}

output "ad_bastion_public_ip" {
    value = aws_instance.windows[0].public_ip
}

output "windows_bastion_password" {
    value = data.template_file.decrypted_keys[0].rendered
}

output "aws_managed_ad_url" {
    description = "Access URL of the new AWS Directory Service Managed Active Directory Server"
    value = aws_directory_service_directory.rancher_eng_ad.access_url
}

output "aws_managed_ad_name" {
    description = "AD Domain Name for the new AWS Directory Service Managed Active Directory Server"
    value = aws_directory_service_directory.rancher_eng_ad.name
}

output "aws_managed_ad_short_name" {
    description = "AD Domain Short Name for the new AWS Directory Service Managed Active Directory Server"
    value = aws_directory_service_directory.rancher_eng_ad.short_name
}

output "aws_managed_ad_password" {
    description = "Administrator password for managing the new AWS Directory Service Managed Active Directory Server"
    value = random_password.this.result
}

output "aws_managed_ad_dns" {
    description = "List of DNS Servers for the new AWS Directory Service Managed Active Directory Server"
    value = aws_directory_service_directory.rancher_eng_ad.dns_ip_addresses
}
