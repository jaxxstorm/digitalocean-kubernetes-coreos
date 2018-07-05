variable "addresses" {
  type = "list"
}

variable "ssh_key" {}

data "rke_node_parameter" "nodes" {
  #count   = "${length(var.addresses)}"
  address = "${var.addresses[count.index]}"
  user    = "core"
  role    = ["controlplane", "worker", "etcd"]
  ssh_key = "${var.ssh_key}"
}

resource rke_cluster "cluster" {
  ignore_docker_version = true
  nodes_conf            = ["${data.rke_node_parameter.nodes.*.json}"]
}
