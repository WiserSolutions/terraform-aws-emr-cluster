variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources"
  default     = true
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
  default     = ""
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  default     = ""
}

variable "name" {
  type        = string
  description = "Name of the application"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  description = "Additional attributes (_e.g._ \"1\")"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (_e.g._ { BusinessUnit : ABC })"
  default     = {}
}

variable "zone_id" {
  type        = string
  description = "Route53 parent zone ID. If provided (not empty), the module will create sub-domain DNS records for the masters and slaves"
  default     = null
}

variable "master_allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of security groups to be allowed to connect to the master instances"
}

variable "slave_allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of security groups to be allowed to connect to the slave instances"
}

variable "master_allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to access the master instances"
}

variable "slave_allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to access the slave instances"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the cluster in (e.g. `vpc-a22222ee`)"
}

variable "master_dns_name" {
  type        = string
  description = "Name of the cluster CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `emr-master-var.name`"
  default     = null
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "subnet_id" {
  type        = string
  description = "VPC subnet ID where you want the job flow to launch. Cannot specify the `cc1.4xlarge` instance type for nodes of a job flow launched in a Amazon VPC"
}

variable "subnet_type" {
  type        = string
  description = "Type of VPC subnet ID where you want the job flow to launch. Supported values are `private` or `public`"
  default     = "private"
}

variable "route_table_id" {
  type        = string
  description = "Route table ID for the VPC S3 Endpoint when launching the EMR cluster in a private subnet. Required when `subnet_type` is `private`"
  default     = ""
}
