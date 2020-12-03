
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
resource "oci_core_vcn" "My_Vcn" {
    # Required
    compartment_id = local.Mycompartment_id
    cidr_block     = "10.0.0.0/16"
    # Optional
    dns_label      = "vcn001"
    display_name   = var.vcn_name
}

locals {
    My_Vcn_id                       = oci_core_vcn.My_Vcn.id
    My_Vcn_dhcp_options_id          = oci_core_vcn.My_Vcn.default_dhcp_options_id
    My_Vcn_domain_name              = oci_core_vcn.My_Vcn.vcn_domain_name
    My_Vcn_default_dhcp_options_id  = oci_core_vcn.My_Vcn.default_dhcp_options_id
    My_Vcn_default_security_list_id = oci_core_vcn.My_Vcn.default_security_list_id
    My_Vcn_default_route_table_id   = oci_core_vcn.My_Vcn.default_route_table_id
}


# ------ Create Internet Gateway
resource "oci_core_internet_gateway" "Igw1" {
    # Required
    compartment_id = local.Mycompartment_id
    vcn_id         = local.My_Vcn_id
    # Optional
    enabled        = true
    display_name   = "IGW1"
}

locals {
    Igw1_id = oci_core_internet_gateway.Igw1.id
}

# ------ Create NAT Gateway
resource "oci_core_nat_gateway" "Natgw1" {
    # Required
    compartment_id = local.Mycompartment_id
    vcn_id         = local.My_Vcn_id
    # Optional
    display_name   = "NATGW1"
    block_traffic  = false
}

locals {
    Natgw1_id = oci_core_nat_gateway.Natgw1.id
}

# ------ Create Security List
# ------- Update VCN Default Security List
resource "oci_core_default_security_list" "Sl_Public" {
    # Required
    manage_default_resource_id = local.My_Vcn_default_security_list_id
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


# ------ Create Security List
resource "oci_core_security_list" "Sl_Private" {
    # Required
    compartment_id = local.Mycompartment_id
    vcn_id         = local.My_Vcn_id
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
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "22"
            max = "22"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "1"
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
    }
    # Optional
    display_name   = "SL_Private"
}

locals {
    Sl_Private_id = oci_core_security_list.Sl_Private.id
}


# ------ Create Route Table
# ------- Update VCN Default Route Table
resource "oci_core_default_route_table" "Rt_Public" {
    # Required
    manage_default_resource_id = local.My_Vcn_default_route_table_id
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


# ------ Create Route Table
resource "oci_core_route_table" "Rt_Private" {
    # Required
    compartment_id = local.Mycompartment_id
    vcn_id         = local.My_Vcn_id
    route_rules    {
        destination_type  = "CIDR_BLOCK"
        destination       = "0.0.0.0/0"
        network_entity_id = local.Natgw1_id
        description       = ""
    }
    # Optional
    display_name   = "RT_Private"
}

locals {
    Rt_Private_id = oci_core_route_table.Rt_Private.id
}


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Subnet_Public" {
    # Required
    compartment_id             = local.Mycompartment_id
    vcn_id                     = local.My_Vcn_id
    cidr_block                 = "10.0.1.0/24"
    # Optional
    display_name               = "Subnet_Public"
    dns_label                  = "sn001"
    security_list_ids          = [local.Sl_Public_id]
    route_table_id             = local.Rt_Public_id
    dhcp_options_id            = local.My_Vcn_dhcp_options_id
    prohibit_public_ip_on_vnic = false
}

locals {
    Subnet_Public_id              = oci_core_subnet.Subnet_Public.id
    Subnet_Public_domain_name     = oci_core_subnet.Subnet_Public.subnet_domain_name
}

# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Subnet_Private" {
    # Required
    compartment_id             = local.Mycompartment_id
    vcn_id                     = local.My_Vcn_id
    cidr_block                 = "10.0.2.0/24"
    # Optional
    display_name               = "Subnet_Private"
    dns_label                  = "sn002"
    security_list_ids          = [local.Sl_Private_id]
    route_table_id             = local.Rt_Private_id
    dhcp_options_id            = local.My_Vcn_dhcp_options_id
    prohibit_public_ip_on_vnic = true
}

locals {
    Subnet_Private_id              = oci_core_subnet.Subnet_Private.id
    Subnet_Private_domain_name     = oci_core_subnet.Subnet_Private.subnet_domain_name
}
