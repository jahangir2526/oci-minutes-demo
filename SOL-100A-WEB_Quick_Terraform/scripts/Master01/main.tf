
# This code is auto generated and any changes will be lost if it is regenerated.

terraform {
    required_version = ">= 0.12.0"
}

# -- Copyright: Copyright (c) 2020, Oracle and/or its affiliates.
# ---- Author : Andrew Hopkinson (Oracle Cloud Solutions A-Team)
# ------ Connect to Provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# ------ Retrieve Regional / Cloud Data
# -------- Get a list of Availability Domains
data "oci_identity_availability_domains" "AvailabilityDomains" {
    compartment_id = var.tenancy_ocid
}
data "template_file" "AvailabilityDomainNames" {
    count    = length(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains)
    template = data.oci_identity_availability_domains.AvailabilityDomains.availability_domains[count.index]["name"]
}
# -------- Get a list of Fault Domains
data "oci_identity_fault_domains" "FaultDomainsAD1" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 0)["name"]
    compartment_id = var.tenancy_ocid
}
data "oci_identity_fault_domains" "FaultDomainsAD2" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 1)["name"]
    compartment_id = var.tenancy_ocid
}
data "oci_identity_fault_domains" "FaultDomainsAD3" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 2)["name"]
    compartment_id = var.tenancy_ocid
}
# -------- Get Home Region Name
data "oci_identity_region_subscriptions" "RegionSubscriptions" {
    tenancy_id = var.tenancy_ocid
}
locals {
    HomeRegion = [for x in data.oci_identity_region_subscriptions.RegionSubscriptions.region_subscriptions: x if x.is_home_region][0]
}
# ------ Get List Service OCIDs
data "oci_core_services" "RegionServices" {
}
# ------ Get List Images
data "oci_core_images" "InstanceImages" {
    compartment_id           = var.compartment_ocid
}


# ------ Create Compartment - Root True
# ------ Root Compartment
locals {
    Mycompartment_id              = var.compartment_ocid
}

output "MycompartmentId" {
    value = local.Mycompartment_id
}

# ------ Create Virtual Cloud Network
resource "oci_core_vcn" "Vcn1" {
    # Required
    compartment_id = local.Mycompartment_id
    cidr_block     = "10.0.0.0/16"
    # Optional
    dns_label      = "vcn001"
    display_name   = var.vcn_name
}

locals {
    Vcn1_id                       = oci_core_vcn.Vcn1.id
    Vcn1_dhcp_options_id          = oci_core_vcn.Vcn1.default_dhcp_options_id
    Vcn1_domain_name              = oci_core_vcn.Vcn1.vcn_domain_name
    Vcn1_default_dhcp_options_id  = oci_core_vcn.Vcn1.default_dhcp_options_id
    Vcn1_default_security_list_id = oci_core_vcn.Vcn1.default_security_list_id
    Vcn1_default_route_table_id   = oci_core_vcn.Vcn1.default_route_table_id
}


# ------ Create Internet Gateway
resource "oci_core_internet_gateway" "Igw1" {
    # Required
    compartment_id = local.Mycompartment_id
    vcn_id         = local.Vcn1_id
    # Optional
    enabled        = true
    display_name   = "IGW1"
}

locals {
    Igw1_id = oci_core_internet_gateway.Igw1.id
}

# ------ Create Security List
# ------- Update VCN Default Security List
resource "oci_core_default_security_list" "Sl_Public" {
    # Required
    manage_default_resource_id = local.Vcn1_default_security_list_id
    egress_security_rules {
        # Required
        protocol    = "all"
        destination = "0.0.0.0/0"
        # Optional
        destination_type  = "CIDR_BLOCK"
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "0.0.0.0/0"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "22"
            max = "22"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "0.0.0.0/0"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "80"
            max = "80"
        }
    }
    # Optional
    display_name   = "SL_Public"
}

locals {
    Sl_Public_id = oci_core_default_security_list.Sl_Public.id
}


# ------ Create Route Table
# ------- Update VCN Default Route Table
resource "oci_core_default_route_table" "Rt_Public" {
    # Required
    manage_default_resource_id = local.Vcn1_default_route_table_id
    route_rules    {
        destination_type  = "CIDR_BLOCK"
        destination       = "0.0.0.0/0"
        network_entity_id = local.Igw1_id
        description       = ""
    }
    # Optional
    display_name   = "RT_Public"
}

locals {
    Rt_Public_id = oci_core_default_route_table.Rt_Public.id
    }


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Subnet_Public" {
    # Required
    compartment_id             = local.Mycompartment_id
    vcn_id                     = local.Vcn1_id
    cidr_block                 = "10.0.1.0/24"
    # Optional
    display_name               = "Subnet_Public"
    dns_label                  = "sn001"
    security_list_ids          = [local.Sl_Public_id]
    route_table_id             = local.Rt_Public_id
    dhcp_options_id            = local.Vcn1_dhcp_options_id
    prohibit_public_ip_on_vnic = false
}

locals {
    Subnet_Public_id              = oci_core_subnet.Subnet_Public.id
    Subnet_Public_domain_name     = oci_core_subnet.Subnet_Public.subnet_domain_name
}

# ------ Get List Images
data "oci_core_images" "Instance1Images" {
    compartment_id           = var.compartment_ocid
    operating_system         = "Oracle Linux"
    operating_system_version = "7.8"
    shape                    = "VM.Standard.E2.1"
}

# ------ Create Instance
resource "oci_core_instance" "Instance1" {
    # Required
    compartment_id      = local.Mycompartment_id
    shape               = "VM.Standard.E2.1"
    # Optional
    display_name        = var.instance_name
    availability_domain = data.oci_identity_availability_domains.AvailabilityDomains.availability_domains["1" - 1]["name"]
    agent_config {
        # Optional
    }
    create_vnic_details {
        # Required
        subnet_id        = local.Subnet_Public_id
        # Optional
        assign_public_ip = true
        display_name     = "instance1 vnic 00"
        hostname_label   = var.host_name
        skip_source_dest_check = false
    }
#    extended_metadata {
#        some_string = "stringA"
#        nested_object = "{\"some_string\": \"stringB\", \"object\": {\"some_string\": \"stringC\"}}"
#    }
    metadata = {
        ssh_authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPG56VM7zHzcknqY4AUWObm2yQ+U+qvLlALIDZFQl1lR57uFBI1ziEaEqxk2BWmjV2fjYBNBVQ/iqKeZbvHtu201Ofy3WaYLCpdr3b8ODx2zO8TAuSiY2gPqFMYcsrwauGPAv8dZ+NDVxQRKsc0qnLnhqUbyckNHVpbf8OZuT/e2rx7WytX75eeoRyOWfOgWcN/x4sl1YxvnxLspPzNQIp9W86itwehkZ5L8rNkcru025k+6GRRIUbWdFemQHCJONBp0mZsHiUHaaRJ/N/Hzk5mZ2SPKAbAJ79HkQyxiOVCminxxL3RHDbCeI2dk4W8/IDVdO1zk0jlKCMpo/iM/mV jaalam@jahangirsmacpro.lan"
        user_data           = base64encode("#!/bin/bash\nyum -y install httpd\nfirewall-offline-cmd --permanent --add-port=80/tcp\nfirewall-offline-cmd --reload\n\necho \"<h1>Welcome to host: $(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.hostname') </h1><hr>\" > /var/www/html/index.html\necho \"<h2>Running on region: $(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.region') </h2><hr>\" >> /var/www/html/index.html\necho \"<h3>Public IP: $(curl -s https://api.ipify.org) </h3><hr>\" >> /var/www/html/index.html\necho \"<h4>Random Name: $(curl -s http://names.drycodes.com/1?format=text&case=upper) </h4>\" >> /var/www/html/index.html\n\nsystemctl stop firewalld\nsystemctl disable firewalld\nsystemctl start httpd\nsystemctl enable httpd\n")
    }
    source_details {
        # Required
        source_id               = data.oci_core_images.Instance1Images.images[0]["id"]
        source_type             = "image"
        # Optional
        boot_volume_size_in_gbs = "50"
#        kms_key_id              = 
    }
    preserve_boot_volume = false
}

locals {
    Instance1_id            = oci_core_instance.Instance1.id
    Instance1_public_ip     = oci_core_instance.Instance1.public_ip
    Instance1_private_ip    = oci_core_instance.Instance1.private_ip
}

output "instance1PublicIP" {
    value = local.Instance1_public_ip
}

output "instance1PrivateIP" {
    value = local.Instance1_private_ip
}

# ------ Create Block Storage Attachments

# ------ Create VNic Attachments

