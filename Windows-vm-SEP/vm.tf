# This is a terraform generated template generated from final

##############################################################
# Keys - CAMC (public/private) & optional User Key (public)
##############################################################
variable "allow_unverified_ssl" {
  description = "Communication with vsphere server with self signed certificate"
  default     = "true"
}



##############################################################
# Define the vsphere provider
##############################################################
provider "vsphere" {
  allow_unverified_ssl = "${var.allow_unverified_ssl}"
  version              = "~> 1.3"
}

##############################################################
# Vsphere data for provider
##############################################################
data "vsphere_datacenter" "vm_datacenter" {
  name = "${var.vm_datacenter}"
}

data "vsphere_datastore" "vm_datastore" {
  name          = "${var.vm_root_disk_datastore}"
  datacenter_id = "${data.vsphere_datacenter.vm_datacenter.id}"
}

data "vsphere_resource_pool" "vm_resource_pool" {
  name          = "${var.vm_resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.vm_datacenter.id}"
}

data "vsphere_network" "vm_network" {
  name          = "${var.vm_network_interface_label}"
  datacenter_id = "${data.vsphere_datacenter.vm_datacenter.id}"
}

data "vsphere_virtual_machine" "vm_template" {
  name          = "${var.vm-image}"
  datacenter_id = "${data.vsphere_datacenter.vm_datacenter.id}"
}

#########################################################
##### Resource : vm
#########################################################
variable "vm_folder" {
  description = "Target vSphere folder for virtual machine"
}

variable "vm_name" {
  description = "Target virtual machine Name"
}

variable "vm_datacenter" {
  description = "Target vSphere datacenter for virtual machine creation"
}

variable "vm_domain" {
  description = "Domain Name of virtual machine"
}

variable "vm_number_of_vcpu" {
  description = "Number of virtual CPU for the virtual machine, which is required to be a positive Integer"
  default     = "1"
}

variable "vm_memory" {
  description = "Memory assigned to the virtual machine in megabytes. This value is required to be an increment of 1024"
  default     = "1024"
}

variable "vm_cluster" {
  description = "Target vSphere cluster to host the virtual machine"
}

variable "vm_resource_pool" {
  description = "Target vSphere Resource Pool to host the virtual machine"
}

variable "vm_dns_suffixes" {
  type        = "list"
  description = "Name resolution suffixes for the virtual network adapter"
}

variable "vm_dns_servers" {
  type        = "list"
  description = "DNS servers for the virtual network adapter"
}

variable "vm_network_interface_label" {
  description = "vSphere port group or network label for virtual machine's vNIC"
}

variable "vm_ipv4_gateway" {
  description = "IPv4 gateway for vNIC configuration"
}

variable "vm_ipv4_address" {
  description = "IPv4 address for vNIC configuration"
}

variable "vm_ipv4_prefix_length" {
  description = "IPv4 prefix length for vNIC configuration. The value must be a number between 8 and 32"
}

variable "vm_adapter_type" {
  description = "Network adapter type for vNIC Configuration"
  default     = "vmxnet3"
}

variable "vm_root_disk_datastore" {
  description = "Data store or storage cluster name for target virtual machine's disks"
}

variable "vm_root_disk_type" {
  type        = "string"
  description = "Type of template disk volume"
  default     = "eager_zeroed"
}

variable "vm_root_disk_controller_type" {
  type        = "string"
  description = "Type of template disk controller"
  default     = "scsi"
}

variable "vm_root_disk_keep_on_remove" {
  type        = "string"
  description = "Delete template disk volume when the virtual machine is deleted"
  default     = "false"
}

variable "vm_root_disk_size" {
  description = "Size of template disk volume. Should be equal to template's disk size"
  default     = "25"
}
variable "sudo_user" {
  description = "specify an username"
  default     = "clouduser"
}

variable "sudo_password_length" {
  description = "specify the password length"
  default     = "20"
}
variable "vm-image" {
  description = "Operating system image id / template that should be used when creating the virtual image"
}

resource "random_id" "password" {
  byte_length = "${var.sudo_password_length * 3 / 4}"
}
# vsphere vm
resource "vsphere_virtual_machine" "vm" {
  name             = "${var.vm_name}" 
  folder           = "${var.vm_folder}"
  num_cpus         = "${var.vm_number_of_vcpu}"
  memory           = "${var.vm_memory}"
  resource_pool_id = "${data.vsphere_resource_pool.vm_resource_pool.id}"
  datastore_id     = "${data.vsphere_datastore.vm_datastore.id}"
  guest_id         = "${data.vsphere_virtual_machine.vm_template.guest_id}"
  scsi_type        = "${data.vsphere_virtual_machine.vm_template.scsi_type}"

  clone {
    template_uuid = "${data.vsphere_virtual_machine.vm_template.id}"

    customize {
      windows_options {
      computer_name = "${var.vm_name}"
      }

      network_interface {
        ipv4_address = "${var.vm_ipv4_address}"
        ipv4_netmask = "${var.vm_ipv4_prefix_length}"
      }

      ipv4_gateway    = "${var.vm_ipv4_gateway}"
      dns_suffix_list = "${var.vm_dns_suffixes}"
      dns_server_list = "${var.vm_dns_servers}"
    }
  }
  

  network_interface {
    network_id   = "${data.vsphere_network.vm_network.id}"
    adapter_type = "${var.vm_adapter_type}"
  }

  disk {
    label          = "${var.vm_name}0.vmdk"
    size           = "${var.vm_root_disk_size}"
    keep_on_remove = "${var.vm_root_disk_keep_on_remove}"
    datastore_id   = "${data.vsphere_datastore.vm_datastore.id}"
  }
  }

resource "vsphere_virtual_machine" "windows" {
  provisioner "chef" {
    server_url = "https://9.109.122.210/organizations/deployment/nodes"
    user_name = "root"
	user_key = "${file("~/.chef/venkatraj.pem")}"
	node_name = "${var.vm_name}"
	recreate_client = true
    connection { 
      type = "winrm"
	  user = "dstadmin"
	  password = "Welcome1@"
      
    }
  }
}
