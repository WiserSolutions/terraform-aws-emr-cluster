module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  enabled    = var.enabled
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

module "label_emr" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("emr")))
}

module "label_ec2" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("ec2")))
}

module "label_ec2_autoscaling" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("ec2", "autoscaling")))
}

module "label_master" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("master")))
}

module "label_slave" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("slave")))
}

module "label_core" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("core")))
}

module "label_master_managed" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("master", "managed")))
}

module "label_slave_managed" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("slave", "managed")))
}

module "label_service_managed" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.14.1"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("service", "managed")))
}

/*
NOTE on EMR-Managed security groups: These security groups will have any missing inbound or outbound access rules added and maintained by AWS,
to ensure proper communication between instances in a cluster. The EMR service will maintain these rules for groups provided
in emr_managed_master_security_group and emr_managed_slave_security_group;
attempts to remove the required rules may succeed, only for the EMR service to re-add them in a matter of minutes.
This may cause Terraform to fail to destroy an environment that contains an EMR cluster, because the EMR service does not revoke rules added on deletion,
leaving a cyclic dependency between the security groups that prevents their deletion.
To avoid this, use the revoke_rules_on_delete optional attribute for any Security Group used in
emr_managed_master_security_group and emr_managed_slave_security_group.
*/

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-sg-specify.html
# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html
# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html

resource "aws_security_group" "managed_master" {
  count                  = var.enabled ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = module.label_master_managed.id
  description            = "EmrManagedMasterSecurityGroup"
  tags                   = module.label_master_managed.tags

  # EMR will update "ingress" and "egress" so we ignore the changes here
  lifecycle {
    ignore_changes = ["ingress", "egress"]
  }
}

resource "aws_security_group_rule" "managed_master_egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = join("", aws_security_group.managed_master.*.id)
}

resource "aws_security_group" "managed_slave" {
  count                  = var.enabled ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = module.label_slave_managed.id
  description            = "EmrManagedSlaveSecurityGroup"
  tags                   = module.label_slave_managed.tags

  # EMR will update "ingress" and "egress" so we ignore the changes here
  lifecycle {
    ignore_changes = ["ingress", "egress"]
  }
}

resource "aws_security_group_rule" "managed_slave_egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = join("", aws_security_group.managed_slave.*.id)
}

resource "aws_security_group" "managed_service_access" {
  count                  = var.enabled && var.subnet_type == "private" ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = module.label_service_managed.id
  description            = "EmrManagedServiceAccessSecurityGroup"
  tags                   = module.label_service_managed.tags

  # EMR will update "ingress" and "egress" so we ignore the changes here
  lifecycle {
    ignore_changes = ["ingress", "egress"]
  }
}

resource "aws_security_group_rule" "managed_service_access_egress" {
  count             = var.enabled && var.subnet_type == "private" ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = join("", aws_security_group.managed_service_access.*.id)
}

# Specify additional master and slave security groups
resource "aws_security_group" "master" {
  count                  = var.enabled ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = module.label_master.id
  description            = "Allow inbound traffic from Security Groups and CIDRs for masters. Allow all outbound traffic"
  tags                   = module.label_master.tags
}

resource "aws_security_group_rule" "master_ingress_security_groups" {
  count                    = var.enabled ? length(var.master_allowed_security_groups) : 0
  description              = "Allow inbound traffic from Security Groups"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.master_allowed_security_groups[count.index]
  security_group_id        = join("", aws_security_group.master.*.id)
}

resource "aws_security_group_rule" "master_ingress_cidr_blocks" {
  count             = var.enabled && length(var.master_allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.master_allowed_cidr_blocks
  security_group_id = join("", aws_security_group.master.*.id)
}

resource "aws_security_group_rule" "master_egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.master.*.id)
}

resource "aws_security_group" "slave" {
  count                  = var.enabled ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = module.label_slave.id
  description            = "Allow inbound traffic from Security Groups and CIDRs for slaves. Allow all outbound traffic"
  tags                   = module.label_slave.tags
}

resource "aws_security_group_rule" "slave_ingress_security_groups" {
  count                    = var.enabled ? length(var.slave_allowed_security_groups) : 0
  description              = "Allow inbound traffic from Security Groups"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.slave_allowed_security_groups[count.index]
  security_group_id        = join("", aws_security_group.slave.*.id)
}

resource "aws_security_group_rule" "slave_ingress_cidr_blocks" {
  count             = var.enabled && length(var.slave_allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.slave_allowed_cidr_blocks
  security_group_id = join("", aws_security_group.slave.*.id)
}

resource "aws_security_group_rule" "slave_egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.slave.*.id)
}

/*
Allows Amazon EMR to call other AWS services on your behalf when provisioning resources and performing service-level actions.
This role is required for all clusters.
https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
*/
data "aws_iam_policy_document" "assume_role_emr" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com", "application-autoscaling.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "emr" {
  count              = var.enabled ? 1 : 0
  name               = module.label_emr.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role_emr.*.json)
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
resource "aws_iam_role_policy_attachment" "emr" {
  count      = var.enabled ? 1 : 0
  role       = join("", aws_iam_role.emr.*.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

/*
Application processes that run on top of the Hadoop ecosystem on cluster instances use this role when they call other AWS services.
For accessing data in Amazon S3 using EMRFS, you can specify different roles to be assumed based on the user or group making the request,
or on the location of data in Amazon S3.
This role is required for all clusters.
https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
*/
data "aws_iam_policy_document" "assume_role_ec2" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2" {
  count              = var.enabled ? 1 : 0
  name               = module.label_ec2.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role_ec2.*.json)
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
resource "aws_iam_role_policy_attachment" "ec2" {
  count      = var.enabled ? 1 : 0
  role       = join("", aws_iam_role.ec2.*.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2" {
  count = var.enabled ? 1 : 0
  name  = join("", aws_iam_role.ec2.*.name)
  role  = join("", aws_iam_role.ec2.*.name)
}

/*
Allows additional actions for dynamically scaling environments. Required only for clusters that use automatic scaling in Amazon EMR.
This role is required for all clusters.
https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
*/
resource "aws_iam_role" "ec2_autoscaling" {
  count              = var.enabled ? 1 : 0
  name               = module.label_ec2_autoscaling.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role_emr.*.json)
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
resource "aws_iam_role_policy_attachment" "ec2_autoscaling" {
  count      = var.enabled ? 1 : 0
  role       = join("", aws_iam_role.ec2_autoscaling.*.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
}
