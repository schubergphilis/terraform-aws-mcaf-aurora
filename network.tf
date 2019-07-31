locals {
  az_ids = [for zone in var.availability_zones : substr(zone, length(zone) - 1, 1)]
  zones  = length(var.subnet_ids) == 0 ? length(var.availability_zones) : 0
}

resource aws_vpc default {
  count                = local.zones > 0 ? 1 : 0
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags                 = merge(var.tags, { "Name" = "${var.stack}-vpc" })
}

resource aws_internet_gateway default {
  count  = local.zones > 0 ? 1 : 0
  vpc_id = aws_vpc.default[0].id
  tags   = merge(var.tags, { "Name" = "${var.stack}-igw" })
}

resource aws_subnet public {
  count                   = local.zones
  cidr_block              = cidrsubnet(aws_vpc.default[0].cidr_block, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.default[0].id

  tags = merge(
    var.tags, { "Name" = "${var.stack}-public-${local.az_ids[count.index]}" }
  )
}

resource aws_route_table public {
  count  = local.zones > 0 ? 1 : 0
  vpc_id = aws_vpc.default[0].id
  tags   = merge(var.tags, { "Name" = "${var.stack}-public" })

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default[0].id
  }
}

resource aws_route_table_association public {
  count          = local.zones
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}
