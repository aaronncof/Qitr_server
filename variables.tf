#############################
## Variables configurables ##
#############################

variable "account-id" {
}

variable "client" {
  # default = "gr"
}

variable "quiter-users" {
  # default = "50"
}

variable "dms-storage" {
  type = number
  # default = 250
}

variable "qae-storage" {
  type = number
  # default = 400
}

variable "client_public_ip" {
  # default = "201.172.148.7"
}

variable "client_subnets_ranges" {
  type = list(string)
} 

##########################################
## tipo de servidor seugun sus usuarios ##
##########################################

variable "dms-instance-type-user" {
  type = map
  default = {
    users_200 = "m5.4xlarge",
    users_126 = "t3.2xlarge",
    users_50 = "t3.2xlarge",
    users_20 = "t3.2xlarge",
    users_12 = "t3.2xlarge"
  }
}

variable "qae-instance-type-user" {
  type = map
  default = {
    users_200 = "t3.2xlarge",
    users_126 = "t3.2xlarge",
    users_50 = "t3.2xlarge",
    users_20 = "t3.2xlarge",
    users_12 = "t3.2xlarge"
  }
}

# --------------------------------------- #

  variable "environment" {
    #default = "${var.client}-production"
    default = "production"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_1" {
  type = map
  default = {
    cidr_block = "10.0.0.0/19",
    az = "us-east-1a"
  }
}

variable "public_subnet_2" {
  type = map
  default = {
    cidr_block = "10.0.32.0/19"
    az = "us-east-1b"
  }
}

variable "public_subnet_3" {
  type = map
  default = {
    cidr_block = "10.0.64.0/19"
    az = "us-east-1c"
  }
}

variable "private_subnet_1" {
  type = map
  default = {
    cidr_block = "10.0.96.0/19"
    az = "us-east-1a"
  }
}

variable "private_subnet_2" {
  type = map
  default = {
    cidr_block = "10.0.128.0/19"
    az = "us-east-1b"
  }
}

variable "private_subnet_3" {
  type = map
  default = {
    cidr_block = "10.0.160.0/19"
    az = "us-east-1c"
  }
}

variable "application_az" {
  default = "us-east-1b"
}

variable "vpn-statica" {
  default = true
}

variable "tc_support_password" {
}
