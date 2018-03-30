variable "name" {
  type        = "string"
  description = "Unique name for the worker pool"
}

# AWS

variable "cluster_name" {
  type        = "string"
  description = "name of the cluster"
}

variable "vpc_id" {
  type        = "string"
  description = "Must be set to `vpc_id` output by cluster"
}

variable "instance_type" {
  type        = "string"
  default     = "t2.small"
  description = "EC2 instance type"
}

variable "ssh_key" {
  type        = "string"
  description = "Name of the key pair to use for worker instances"
}

variable "count" {
  type        = "string"
  default     = "1"
  description = "Number of instances"
}

variable "disk_size" {
  type        = "string"
  default     = "40"
  description = "Size of the EBS volume in GB"
}

variable "public_subnets" {
  type        = "list"
  description = "List of public subnets"
}
